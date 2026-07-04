terraform {
  backend "s3" {
    bucket         = "replace-with-your-state-bucket"
    key            = "paymentology/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "replace-with-your-lock-table"
    encrypt        = true
  }
}
