resource "aws_security_group" "tfer--dsit-llmlite-gateway-main-bedrock-vpce_sg-0e2fac28cbfe8b0a5" {
  description = "Allows HTTPS traffic from Fargate to connect to Amazon Bedrock."

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port       = "443"
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-fargate-sg_sg-07a7dea82a134b0c8_id}"]
    self            = "false"
    to_port         = "443"
  }

  name = "dsit-llmlite-gateway-main-bedrock-vpce"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-bedrock-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-bedrock-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "vpc-0b5fd89b4223abdc9"
}

resource "aws_security_group" "tfer--dsit-llmlite-gateway-main-fargate-sg_sg-07a7dea82a134b0c8" {
  description = "Allows ALB to acess the Fargate Service"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "443"
    protocol    = "tcp"
    self        = "false"
    to_port     = "443"
  }

  egress {
    from_port       = "5432"
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-rds-sg_sg-042eb3ca28cbe1b1a_id}"]
    self            = "false"
    to_port         = "5432"
  }

  ingress {
    from_port       = "0"
    protocol        = "-1"
    security_groups = ["sg-0d57a68abe5cdaba4"]
    self            = "false"
    to_port         = "0"
  }

  name = "dsit-llmlite-gateway-main-fargate-sg"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-fargate-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-fargate-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "vpc-0b5fd89b4223abdc9"
}

resource "aws_security_group" "tfer--dsit-llmlite-gateway-main-rds-sg_sg-042eb3ca28cbe1b1a" {
  description = "Allow access to LiteLLM PostgreSQL database"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "tcp"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    from_port       = "5432"
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-fargate-sg_sg-07a7dea82a134b0c8_id}"]
    self            = "false"
    to_port         = "5432"
  }

  name = "dsit-llmlite-gateway-main-rds-sg"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-rds-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-rds-sg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "vpc-0b5fd89b4223abdc9"
}
