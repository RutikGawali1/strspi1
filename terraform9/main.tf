provider "aws" {
  region = var.region
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets (IDs)
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Subnet details (for AZ info)
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Use 1 subnet per AZ for ALB
locals {
  az_subnet_map = {
    for subnet_id, subnet in data.aws_subnet.details :
    subnet.availability_zone => subnet.id...
  }

  unique_subnets_for_alb = [
    for az, subnets in local.az_subnet_map : subnets[0]
  ]
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-rutik-t9"
  description = "Allow HTTP access to ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Task Security Group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-rutik-t9"
  description = "Allow ALB to reach ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster (no capacity config here)
resource "aws_ecs_cluster" "strapi" {
  name = "rutik-cluster-t9"
}

# Attach FARGATE_SPOT as default capacity provider
resource "aws_ecs_cluster_capacity_providers" "strapi_cp" {
  cluster_name = aws_ecs_cluster.strapi.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}


# ECS Task Definition
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task-t9"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = "arn:aws:iam::607700977843:role/ecs-task-execution-role"
  task_role_arn      = "arn:aws:iam::607700977843:role/ecs-task-execution-role"

  container_definitions = jsonencode([{
    name      = "strapi"
    image     = var.docker_image
    essential = true
    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
    }],
    environment = [
      { name = "PORT", value = tostring(var.app_port) },
      { name = "DATABASE_CLIENT", value = "sqlite" },
      { name = "APP_KEYS", value = "Rd4EZ4S13CKp1JlAMzxk5A==,R4GDtWxkpBkJuK2Aq4Pv7g==,Q7df6Erx8xr6N6QFwlT4ig==,DUQwEBTNfE5qamNS1y97Xw==" },
      { name = "API_TOKEN_SALT", value = "y6QBwgHTWetn4KoRl7MDTA==" },
      { name = "ADMIN_JWT_SECRET", value = "IbscCljtmC/t/KWWOFYOAg==" },
      { name = "STRAPI_ENABLE_CONTENT_TYPE_BUILDER", value = "true" }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/ecs/strapi-rutik-t9"
        awslogs-region        = var.region
        awslogs-stream-prefix = "strapi"
      }
    }
  }])

  depends_on = [aws_cloudwatch_log_group.strapi]
}

# Application Load Balancer
resource "aws_lb" "strapi" {
  name               = "strapi-alb-rutik-t9"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.unique_subnets_for_alb
}

# Target Group
resource "aws_lb_target_group" "strapi" {
  name        = "strapi-tg-rutik-t9"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-399"
  }
}

# ALB Listener
resource "aws_lb_listener" "strapi" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }
}

# ECS Service using FARGATE_SPOT capacity provider
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service-t9"
  cluster         = aws_ecs_cluster.strapi.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = null # Required to use capacity providers

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = local.unique_subnets_for_alb
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi.arn
    container_name   = "strapi"
    container_port   = var.app_port
  }

  depends_on = [
    aws_lb_listener.strapi,
    aws_ecs_cluster_capacity_providers.strapi_cp
  ]
}
