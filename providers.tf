provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "zura-bucket"
    key = "minitask.tf"
    encrypt = true
    region = "eu-central-1"
  }
}