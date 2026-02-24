resource "aws_route_table" "tfer--rtb-01741c1b4cfae92c7" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "nat-1766d32e38494d5e2"
  }

  tags = {
    Name = "dsit-llmlite-gateway-main-private-rt-2a"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-private-rt-2a"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_route_table" "tfer--rtb-06335f764ef3fbfe6" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-072726bf27f2c7493"
  }

  tags = {
    Name = "dsit-llmlite-gateway-main-route-table"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-route-table"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_route_table" "tfer--rtb-06701cb3e1e49d646" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-072726bf27f2c7493"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_route_table" "tfer--rtb-068d6b7b95412ca2b" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "nat-1374a32db29b24b93"
  }

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-rt-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-rt-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_route_table" "tfer--rtb-08f1893829b77f444" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "igw-072726bf27f2c7493"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_route_table" "tfer--rtb-0b95cb5d7ddee8676" {
  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}
