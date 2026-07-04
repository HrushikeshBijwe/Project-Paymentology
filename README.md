# Paymentology Terraform Project

This repository provides a modular Terraform baseline for deploying a secure, highly available AWS web application architecture with:

- VPC with public, private, and optional database subnets
- Application Load Balancer in public subnets
- EC2 web tier in private subnets behind an Auto Scaling Group
- API Gateway fronting the ALB for REST API access
- Optional CloudFront CDN and WAF protection for global delivery and security
- Security groups following least-privilege principles
- CloudWatch log group and SNS topic for monitoring and alerting
- GitHub Actions CI/CD workflow with separate init, validate, plan, approval, apply, and destroy stages

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

## GitHub Actions CI/CD

- Workflow file: `.github/workflows/terraform.yml`
- Triggers:
  - `pull_request` on `dev` and `main`
  - manual `workflow_dispatch` with `environment` and `action` inputs
- Stages:
  - `init` — runs `terraform init -reconfigure`
  - `validate` — checks formatting and runs `terraform validate`
  - `plan` — creates a plan for selected environment and uploads it as an artifact
  - `approval` — manual gate for `apply` and `destroy`
  - `apply` — executes the uploaded plan
  - `destroy` — destroys the selected environment
- Use `environment` input to choose `dev` or `prod`
- Use `action` input to choose `plan`, `apply`, or `destroy`

## Environment-specific web tier message

The EC2 web instances use a cloud-init template under `modules/compute/templates/user_data.sh`.
The page text now includes the deployment environment, for example `Terraform-managed web tier in dev environment`.

## Structure

- modules/networking: VPC, subnets, route tables, NAT gateways
- modules/security: security groups
- modules/loadbalancer: ALB and target group
- modules/api_gateway: REST API Gateway backed by the ALB
- modules/cloudfront: CloudFront distribution for CDN delivery
- modules/waf: WAF ACLs for CloudFront and ALB
- modules/compute: launch template and Auto Scaling Group
- modules/monitoring: logging and alerting
- environments/dev and environments/prod: environment-specific values

## Notes

- The current implementation uses a basic Apache web page on Amazon Linux 2.
- API Gateway is configured to route REST requests to the ALB.
- A CloudFront module is available for CDN distribution, and WAF is included for CloudFront and ALB protection.
- HTTPS/TLS termination is intentionally left as a follow-up step to be wired to ACM certificates.
- For production, add remote state storage such as S3 + DynamoDB and tighten SG rules further.
