# logs.tf

# Set up CloudWatch group and log stream and retain logs for 1 days
resource "aws_cloudwatch_log_group" "AIOPS_log_group" {
  name              = "/ecs/AIOPS"
  retention_in_days = 30
  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}

resource "aws_cloudwatch_log_stream" "AIOPS_log_stream" {
  name           = "my-log-stream"
  log_group_name = aws_cloudwatch_log_group.AIOPS_log_group.name
}
/*output "cloud_watch_logs_log_group_arn" {
  value = data.aws_cloudwatch_logs_log_group.AIOPS_log_group.arn
}

data "aws_cloudwatch_log_group" "AIOPS_log_group" {
  name              = "/ecs/AIOPS"
  retention_in_days = 1

  tags = {
    Environment = "AIOPS"
    Project     = "POC"
  }
}*/


