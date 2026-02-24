output "tf_state_bucket" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.tfstate.id
}

output "tf_state_dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking."
  value       = aws_dynamodb_table.tfstate_lock.name
}
