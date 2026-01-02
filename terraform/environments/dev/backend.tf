terraform {
  backend "s3" {
    bucket         = "ecommerce-tf-state-dev" # Change this to your bucket name
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ecommerce-terraform-lock" # Change this to your table name
  }
}