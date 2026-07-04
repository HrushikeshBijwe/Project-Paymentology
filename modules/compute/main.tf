data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    app_name = var.project_name
  }))

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = [var.web_security_group_id]

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = "${var.project_name}-web" })
  }
}

resource "aws_autoscaling_group" "web" {
  name                     = "${var.project_name}-asg"
  desired_capacity         = var.desired_capacity
  max_size                 = var.max_size
  min_size                 = var.min_size
  vpc_zone_identifier      = var.private_subnet_ids
  target_group_arns        = [var.target_group_arn]
  health_check_type        = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web"
    propagate_at_launch = true
  }
}
