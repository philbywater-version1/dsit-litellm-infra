resource "aws_network_acl" "tfer--acl-0ec40d6a7707c8c05" {
  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "1024"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "120"
    to_port    = "65535"
  }

  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "443"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "110"
    to_port    = "443"
  }

  egress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "80"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "100"
    to_port    = "80"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "1024"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "120"
    to_port    = "65535"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "443"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "110"
    to_port    = "443"
  }

  ingress {
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = "80"
    icmp_code  = "0"
    icmp_type  = "0"
    protocol   = "6"
    rule_no    = "100"
    to_port    = "80"
  }

  subnet_ids = ["${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0310f584f58ff14b6_id}", "${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-08ea423079f9d34de_id}"]

  tags = {
    Name = "dsit-llmlite-gateway-main-public-nacl"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-public-nacl"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}
