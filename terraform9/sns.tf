# Create SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "alarm_topic" {
  name = "ecs-strapi-alarm-topic"
}

# Subscribe your email to the SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = "rutikgawali101@gmail.com"  
}
