provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    key = "litellm/ecs/terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
  }
}
