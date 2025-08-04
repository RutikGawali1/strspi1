resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "Strapi-ECS-Dashboard-rutik"

  dashboard_body = jsonencode({
    widgets = [

      # 🔘 CPU Gauge - Left column
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 6,
        height = 4,
        properties = {
          view = "singleValue",
          metrics = [
            [ "ECS/ContainerInsights", "CpuUtilized", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name, { "stat": "Average" } ]
          ],
          region = var.region,
          title = "CPU Utilization (%)",
          sparkline = false,
          setPeriodToTimeRange = true
        }
      },

      # 🔘 Memory Gauge - Right column
      {
        type = "metric",
        x = 6,
        y = 0,
        width = 6,
        height = 4,
        properties = {
          view = "singleValue",
          metrics = [
            [ "ECS/ContainerInsights", "MemoryUtilized", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name, { "stat": "Average" } ]
          ],
          region = var.region,
          title = "Memory Utilization (%)",
          sparkline = false,
          setPeriodToTimeRange = true
        }
      },

      # 📈 Line chart - Full width
      {
        type = "metric",
        x = 0,
        y = 4,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "ECS/ContainerInsights", "CpuUtilized", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name, { "stat": "Average" } ],
            [ ".", "MemoryUtilized", ".", ".", ".", ".", { "stat": "Average" } ]
          ],
          region = var.region,
          period = 60,
          title = "CPU & Memory Utilization Trend"
        }
      },

      # 🧮 Task Count - Left
      {
        type = "metric",
        x = 0,
        y = 10,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            [ "ECS/ContainerInsights", "RunningTaskCount", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name ]
          ],
          region = var.region,
          stat = "Average",
          period = 60,
          title = "Running Task Count"
        }
      },

      # ⏱️ ALB Response Time - Right
      {
        type = "metric",
        x = 6,
        y = 10,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.strapi.arn_suffix ]
          ],
          region = var.region,
          stat = "Average",
          period = 60,
          title = "ALB Target Response Time"
        }
      },

      # 📶 Network I/O - Full width
      {
        type = "metric",
        x = 0,
        y = 16,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "ECS/ContainerInsights", "NetworkRxBytes", "ClusterName", aws_ecs_cluster.strapi.name, "ServiceName", aws_ecs_service.strapi.name, { "stat": "Sum" } ],
            [ ".", "NetworkTxBytes", ".", ".", ".", ".", { "stat": "Sum" } ]
          ],
          region = var.region,
          period = 60,
          title = "Network In/Out (Bytes)"
        }
      }

    ]
  })
}
