resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/ecs/${var.project_name}-web"
  retention_in_days = 30

  tags = merge(var.tags, { Name = "${var.project_name}-web-logs" })
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}
