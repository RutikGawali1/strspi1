# -----------------------
# CPU Utilization Alarm
# -----------------------
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "Strapi-High-CPU-rutik"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers if ECS CPU usage is over 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}

# -----------------------
# Memory Utilization Alarm
# -----------------------
resource "aws_cloudwatch_metric_alarm" "high_memory_alarm" {
  alarm_name          = "Strapi-High-Memory-rutik"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggers if ECS memory usage is over 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}

# -----------------------
# Task Count Alarm (Health Check)
# -----------------------
resource "aws_cloudwatch_metric_alarm" "task_health_alarm" {
  alarm_name          = "Strapi-Task-Health-rutik"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Triggers if ECS running tasks drop below 1 (unhealthy state)"
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi.name
    ServiceName = aws_ecs_service.strapi.name
  }

  alarm_actions = [aws_sns_topic.alarm_topic.arn]
}
