terraform {
  backend "s3" {
    encrypt        = true
    region         = "eu-central-1"
    key            = "example.tfstate"
    bucket         = "11111111111-terraform-state"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "eu-central-1"
}
