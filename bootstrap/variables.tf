variable "tf_state_bucket" {
  description = "Name of the S3 bucket to create for Terraform remote state storage."
  type        = string
}

variable "tf_state_dynamodb_table" {
  description = "Name of the DynamoDB table to create for Terraform state locking."
  type        = string
}
