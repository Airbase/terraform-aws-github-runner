terraform {
  backend "s3" {
    bucket         = "airbase-infrastructure"
    key            = "terraform/github-aws-runners/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-github-actions-runners-lock"
  }
}