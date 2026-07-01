#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html>
  <head><title>${app_name} Web App</title></head>
  <body><h1>Welcome to ${app_name}</h1><p>Terraform-managed web tier</p></body>
</html>
EOF
