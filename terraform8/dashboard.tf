resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "Strapi-ECS-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          title = "CPU Utilization",
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name ]
          ],
          region = var.region,
          stat = "Average",
          period = 60,
          view = "timeSeries"
        }
      },
      {
        type = "metric",
        x = 12,
        y = 0,
        width = 12,
        height = 6,
        properties = {
          title = "Memory Utilization",
          metrics = [
            [ "AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name ]
          ],
          region = var.region,
          stat = "Average",
          period = 60,
          view = "timeSeries"
        }
      }
    ]
  })
}
