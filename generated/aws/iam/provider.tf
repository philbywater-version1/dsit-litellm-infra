provider "aws" {}

terraform {
  backend "s3" {
    key = "litellm/iam/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}
