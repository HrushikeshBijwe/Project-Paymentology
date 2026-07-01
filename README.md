# Paymentology Terraform Project

This repository provides a modular Terraform baseline for deploying a secure, highly available AWS web application architecture with:

- VPC with public, private, and optional database subnets
- Application Load Balancer in public subnets
- EC2 web tier in private subnets behind an Auto Scaling Group
- Security groups following least-privilege principles
- CloudWatch log group and SNS topic for monitoring and alerting
- GitLab CI/CD workflow for validate, plan, and apply stages

## Architecture summary

- Public subnets host the ALB and internet-facing components.
- Private subnets host the web application instances.
- Optional database subnets are available for future RDS or similar services.
- The ALB forwards traffic to the EC2 instances via a target group.

## Prerequisites

- Terraform v1.5+
- AWS CLI configured with credentials
- An AWS account with permissions for VPC, EC2, ELB, CloudWatch, and IAM resources

## Usage

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Select or create a workspace:
   ```bash
   terraform workspace select dev || terraform workspace new dev
   ```

3. Review the plan:
   ```bash
   terraform plan -var-file=environments/dev/terraform.tfvars
   ```

4. Apply the deployment:
   ```bash
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

## Structure

- modules/networking: VPC, subnets, route tables, NAT gateways
- modules/security: security groups
- modules/loadbalancer: ALB and target group
- modules/compute: launch template and Auto Scaling Group
- modules/monitoring: logging and alerting
- environments/dev and environments/prod: environment-specific values

## Notes

- The current implementation uses a basic Apache web page on Amazon Linux 2.
- HTTPS/TLS termination is intentionally left as a follow-up step to be wired to ACM certificates.
- For production, add remote state storage such as S3 + DynamoDB and tighten SG rules further.
