resource "aws_cloudwatch_log_group" "web" {
  name              = "/aws/ecs/${var.project_name}-web"
  retention_in_days = 30

  tags = merge(var.tags, { Name = "${var.project_name}-web-logs" })
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-HighCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Trigger when EC2 CPU utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-HighMemory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Trigger when EC2 memory utilization is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_disk" {
  alarm_name          = "${var.project_name}-HighDiskUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "Trigger when EC2 disk usage is high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_network_in" {
  alarm_name          = "${var.project_name}-HighNetworkIn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000
  alarm_description   = "Trigger when EC2 incoming network traffic is unexpectedly high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "high_network_out" {
  alarm_name          = "${var.project_name}-HighNetworkOut"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 50000000
  alarm_description   = "Trigger when EC2 outgoing network traffic is unexpectedly high"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_status_check" {
  alarm_name          = "${var.project_name}-InstanceStatusFailed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Trigger when any EC2 instance status check fails"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-ALB-5xxErrors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Trigger when ALB target group returns too many 5XX responses"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-ALB-UnhealthyHosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Trigger when there are unhealthy hosts behind the ALB"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}
