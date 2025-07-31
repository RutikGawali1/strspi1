variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "app_port" {
  description = "Port Strapi app listens on"
  default     = 1337
}

variable "docker_image" {
  description = "Docker image to deploy"
  default     = "607700977843.dkr.ecr.us-east-2.amazonaws.com/strapi-app-rutik:latest"
}

variable "execution_role_arn" {
  description = "IAM Role ARN for ECS Task Execution"
  type        = string
  default     = "arn:aws:iam::607700977843:role/ecs-task-execution-role"
}

variable "codedeploy_role_arn" {
  description = "IAM Role ARN for CodeDeploy"
  type        = string
  default     = "arn:aws:iam::607700977843:role/CodeDeployServiceRole"
}

# Optional customization variables
variable "codedeploy_app_name" {
  description = "CodeDeploy application name"
  type        = string
  default     = "strapi-codedeploy-app"
}

variable "deployment_group_name" {
  description = "CodeDeploy deployment group name"
  type        = string
  default     = "strapi-deployment-group"
}

variable "ecs_cluster_name" {
  description = "Name of ECS cluster"
  type        = string
  default     = "rutik-cluster-t11"
}

variable "ecs_service_name" {
  description = "Name of ECS service"
  type        = string
  default     = "strapi-service-t11"
}

variable "app_name" {
  description = "Base name for ECS and CodeDeploy resources"
  default     = "strapi"
}
