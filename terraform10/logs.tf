resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/strapi-rutik-t9"
  retention_in_days = 7
}
