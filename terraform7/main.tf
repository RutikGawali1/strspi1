provider "aws" {
  region = var.region
}

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Use 2 subnets for ALB
locals {
  unique_subnets_for_alb = slice(data.aws_subnets.default.ids, 0, 2)
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi-rutik-t7"
  retention_in_days = 7
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-rutik-t7"
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
  name        = "ecs-sg-rutik-t7"
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

# ECS Cluster
resource "aws_ecs_cluster" "strapi" {
  name = "rutik-cluster-t7"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task-t7"
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
      { name = "ADMIN_JWT_SECRET", value = "IbscCljtmC/t/KWWOFYOAg==" }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group         = "/ecs/strapi-rutik-t7"
        awslogs-region        = var.region
        awslogs-stream-prefix = "strapi"
      }
    }
  }])

  depends_on = [aws_cloudwatch_log_group.strapi]
}

# ALB
resource "aws_lb" "strapi" {
  name               = "strapi-alb-rutik-t7"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.unique_subnets_for_alb
}

# Target Group
resource "aws_lb_target_group" "strapi" {
  name        = "strapi-tg-rutik-t7"
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

# Listener
resource "aws_lb_listener" "strapi" {
  load_balancer_arn = aws_lb.strapi.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi.arn
  }
}

# ECS Fargate Service
resource "aws_ecs_service" "strapi" {
  name            = "strapi-service-t7"
  cluster         = aws_ecs_cluster.strapi.id
  task_definition = aws_ecs_task_definition.strapi.arn
  launch_type     = "FARGATE"
  desired_count   = 1

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

  depends_on = [aws_lb_listener.strapi]
}
