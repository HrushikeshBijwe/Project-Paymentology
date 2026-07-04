#!/bin/bash
yum update -y
yum install -y httpd amazon-cloudwatch-agent
systemctl enable httpd
systemctl start httpd
cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html>
  <head><title>${app_name} Web App</title></head>
  <body><h1>Welcome Sarang to Paymentology</h1><p>Terraform-managed web tier in ${environment} environment</p></body>
</html>
EOF
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "metrics": {
    "namespace": "CWAgent",
    "append_dimensions": {
      "InstanceId": "$${aws:InstanceId}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["/"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
