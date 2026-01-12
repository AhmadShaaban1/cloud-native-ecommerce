terraform {
  backend "s3" {
    bucket         = "ecommerce-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ecommerce-terraform-lock-prod"
  }
}