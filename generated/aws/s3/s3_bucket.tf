resource "aws_s3_bucket" "tfer--config-bucket-072136646002" {
  bucket        = "config-bucket-072136646002"
  force_destroy = "false"

  grant {
    id          = "4196fd920c777d1f613f369196f7b4ad8d95bc63c7fcffcc882b6e524a57b465"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  object_lock_enabled = "false"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "s3:GetBucketAcl",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "072136646002"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::config-bucket-072136646002",
      "Sid": "AWSConfigBucketPermissionsCheck"
    },
    {
      "Action": "s3:ListBucket",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "072136646002"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::config-bucket-072136646002",
      "Sid": "AWSConfigBucketExistenceCheck"
    },
    {
      "Action": "s3:PutObject",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "072136646002",
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::config-bucket-072136646002/AWSLogs/072136646002/Config/*",
      "Sid": "AWSConfigBucketDelivery"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  request_payer = "BucketOwner"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }

      bucket_key_enabled = "false"
    }
  }

  versioning {
    enabled    = "false"
    mfa_delete = "false"
  }
}

resource "aws_s3_bucket" "tfer--terraform-20260224132347096200000001" {
  bucket        = "terraform-20260224132347096200000001"
  force_destroy = "false"

  grant {
    id          = "4196fd920c777d1f613f369196f7b4ad8d95bc63c7fcffcc882b6e524a57b465"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }

  object_lock_enabled = "false"
  request_payer       = "BucketOwner"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }

      bucket_key_enabled = "false"
    }
  }

  versioning {
    enabled    = "false"
    mfa_delete = "false"
  }
}
