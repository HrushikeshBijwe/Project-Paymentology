terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "replace-with-your-state-bucket"
    key    = "paymentology/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  az_count                = var.az_count
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs
  create_database_subnets = var.create_database_subnets
  tags                    = local.common_tags
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.networking.vpc_id
  tags         = local.common_tags
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name          = var.project_name
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  tags                  = local.common_tags
}

module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
  alb_arn      = module.loadbalancer.alb_arn
  tags         = local.common_tags
}

module "cloudfront" {
  source             = "./modules/cloudfront"
  project_name       = var.project_name
  origin_domain_name = module.loadbalancer.alb_dns_name
  web_acl_arn        = module.waf.cloudfront_web_acl_arn
  tags               = local.common_tags
}

module "api_gateway" {
  source       = "./modules/api_gateway"
  project_name = var.project_name
  aws_region   = var.aws_region
  alb_dns_name = module.loadbalancer.alb_dns_name
  stage_name   = var.environment
  tags         = local.common_tags
}

module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  private_subnet_ids    = module.networking.private_subnet_ids
  web_security_group_id = module.security.web_security_group_id
  target_group_arn      = module.loadbalancer.target_group_arn
  instance_profile_name = module.iam.instance_profile_name
  tags                  = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name            = var.project_name
  alb_name                = module.loadbalancer.alb_name
  alb_arn_suffix          = module.loadbalancer.alb_arn_suffix
  target_group_arn_suffix = module.loadbalancer.target_group_arn_suffix
  auto_scaling_group_name = module.compute.asg_name
  tags                    = local.common_tags
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  tags         = local.common_tags
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}
