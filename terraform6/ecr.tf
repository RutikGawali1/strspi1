resource "aws_ecr_repository" "strapi_app" {
  name                 = "strapi-app-rutik"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "strapi-app-rutik"
    Environment = "production"
  }
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.strapi_app.repository_url
}
