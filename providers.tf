terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.7.0"
    }
  }
}

# Refers to the AWS_PROFILE environment variable.
provider "aws" {
  region  = "ap-northeast-2"
}
