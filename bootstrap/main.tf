# bootstrap/main.tf
# ----------------------------------------------------------------------------
# One-time apply to create the S3 bucket and DynamoDB table that all
# other modules use as their Terraform remote state backend.
#
# Run once before any other module:
#   cd bootstrap
#   terraform init
#   terraform apply
# ----------------------------------------------------------------------------

resource "aws_s3_bucket" "tfstate" {
  bucket = var.tf_state_bucket

  tags = {
    Name        = var.tf_state_bucket
    Description = "Terraform remote state for dsit-litellm-infra"
    Title       = "AIEL"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = var.tf_state_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = var.tf_state_dynamodb_table
    Description = "Terraform state lock for dsit-litellm-infra"
    Title       = "AIEL"
  }
}
