resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Strapi-High-CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }

  alarm_description   = "Triggers if CPU usage is over 80%"
  treat_missing_data  = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "high_memory_alarm" {
  alarm_name          = "Strapi-High-Memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }

  alarm_description   = "Triggers if memory usage is over 80%"
  treat_missing_data  = "notBreaching"
}
