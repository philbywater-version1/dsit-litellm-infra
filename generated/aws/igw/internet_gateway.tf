resource "aws_internet_gateway" "tfer--igw-072726bf27f2c7493" {
  tags = {
    Name = "dsit-llmlite-gateway-main-igw"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-igw"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_internet_gateway" "tfer--igw-08ad261f6b0871495" {
  vpc_id = "vpc-0bd86a9b6d959b819"
}
