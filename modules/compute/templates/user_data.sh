#!/bin/bash
yum update -y
yum install -y httpd amazon-cloudwatch-agent mod_ssl
systemctl enable httpd
systemctl start httpd
cat > /var/www/html/index.html <<'EOF'
<!doctype html>
<html>
  <head><title>${app_name} Web App</title></head>
  <body><h1>Welcome to Paymentology</h1><p>Terraform-managed web tier in ${environment} environment</p></body>
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

# Install provided TLS certificate and enable HTTPS if PEMs were supplied
if [ -n "${tls_certificate_pem}" ] && [ -n "${tls_private_key_pem}" ]; then
  mkdir -p /etc/pki/tls/certs /etc/pki/tls/private
  cat > /etc/pki/tls/certs/paymentology.crt <<'CERT'
${tls_certificate_pem}
CERT

  cat > /etc/pki/tls/private/paymentology.key <<'KEY'
${tls_private_key_pem}
KEY

  chmod 600 /etc/pki/tls/private/paymentology.key

  cat > /etc/httpd/conf.d/paymentology-ssl.conf <<'CONF'
<VirtualHost *:443>
  ServerName localhost
  DocumentRoot /var/www/html
  SSLEngine on
  SSLCertificateFile /etc/pki/tls/certs/paymentology.crt
  SSLCertificateKeyFile /etc/pki/tls/private/paymentology.key
  <Directory "/var/www/html">
    Require all granted
  </Directory>
</VirtualHost>
CONF

  systemctl restart httpd
fi
