provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "zura-bucket"
    key = "minitask.tf"
    encrypt = true
    region = "eu-central-1"
  }
}