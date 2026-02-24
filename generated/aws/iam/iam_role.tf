resource "aws_iam_role" "tfer--dsit-litellm-fg-bedrock-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  description          = "Allows ECS tasks to call AWS services on your behalf."
  max_session_duration = "3600"
  name                 = "dsit-litellm-fg-bedrock-role"
  path                 = "/"

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

resource "aws_iam_role" "tfer--dsit-litellm-gateway-main-task-admin" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:ecs:eu-west-2:072136646002:*"
        },
        "StringEquals": {
          "aws:SourceAccount": "072136646002"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "dsit-litellm-gateway-main-task-admin"
  path                 = "/"

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

resource "aws_iam_role" "tfer--dsit-litellm-gateway-main-task-execution-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:ecs:eu-west-2:072136646002:*"
        },
        "StringEquals": {
          "aws:SourceAccount": "072136646002"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "dsit-litellm-gateway-main-task-execution-role"
  path                 = "/"

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

resource "aws_iam_role" "tfer--dsit-task-execution-role" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:ecs:eu-west-2:072136646002:*"
        },
        "StringEquals": {
          "aws:SourceAccount": "072136646002"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "dsit-task-execution-role"
  path                 = "/"

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

resource "aws_iam_role_policy_attachment" "tfer--dsit-litellm-fg-bedrock-role-bedrock" {
  role       = aws_iam_role.tfer--dsit-litellm-fg-bedrock-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockLimitedAccess"
}

resource "aws_iam_role_policy_attachment" "tfer--dsit-litellm-gateway-main-task-admin-admin" {
  role       = aws_iam_role.tfer--dsit-litellm-gateway-main-task-admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "tfer--dsit-litellm-gateway-main-task-execution-role-ecs" {
  role       = aws_iam_role.tfer--dsit-litellm-gateway-main-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "tfer--dsit-task-execution-role-ssm" {
  role       = aws_iam_role.tfer--dsit-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "tfer--dsit-task-execution-role-ecs" {
  role       = aws_iam_role.tfer--dsit-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
