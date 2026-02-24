variable "tf_state_bucket" {
  description = "S3 bucket name for Terraform remote state. Set via TF_VAR_tf_state_bucket."
  type        = string
}

data "terraform_remote_state" "alb" {
  backend = "s3"

  config = {
    bucket = var.tf_state_bucket
    key    = "litellm/alb/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket = var.tf_state_bucket
    key    = "litellm/sg/terraform.tfstate"
    region = "eu-west-2"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "s3"

  config = {
    bucket = var.tf_state_bucket
    key    = "litellm/subnet/terraform.tfstate"
    region = "eu-west-2"
  }
}
