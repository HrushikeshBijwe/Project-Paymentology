terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "sarang-paymentology-bucket"
    key            = "paymentology/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sarang-paymentology-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}