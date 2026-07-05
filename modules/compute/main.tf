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
  key_name = var.ssh_key_name != "" ? var.ssh_key_name : (length(aws_key_pair.deploy_key) > 0 ? aws_key_pair.deploy_key[0].key_name : null)

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    app_name    = var.project_name
    environment = var.environment
    # tls_certificate_pem = var.tls_certificate_pem
    # tls_private_key_pem = var.tls_private_key_pem
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

resource "aws_key_pair" "deploy_key" {
  count    = length(var.ssh_public_key) > 0 ? 1 : 0
  key_name = var.ssh_key_name != "" ? var.ssh_key_name : "${var.project_name}-ssh-key"
  public_key = var.ssh_public_key
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.project_name}-asg"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
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
