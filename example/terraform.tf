terraform {
  backend "s3" {
    encrypt        = true
    region         = "eu-central-1"
    key            = "example.tfstate"
    bucket         = "902345625770-terraform-state"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "eu-central-1"
}
