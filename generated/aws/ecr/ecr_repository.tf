resource "aws_ecr_repository" "tfer--litellm" {
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = "true"
  }

  image_tag_mutability = "MUTABLE"
  name                 = "litellm"

  tags = {
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}
