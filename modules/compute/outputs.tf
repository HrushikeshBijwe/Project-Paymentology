output "asg_name" {
  value = aws_autoscaling_group.web.name
}

output "ssh_key_name" {
  description = "Effective SSH key name assigned to instances (either provided or created)"
  value = var.ssh_key_name != "" ? var.ssh_key_name : (length(aws_key_pair.deploy_key) > 0 ? aws_key_pair.deploy_key[0].key_name : null)
}
