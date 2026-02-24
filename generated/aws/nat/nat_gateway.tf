resource "aws_nat_gateway" "tfer--nat-1374a32db29b24b93" {
  connectivity_type                  = "public"
  subnet_id                          = data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0310f584f58ff14b6_id
  secondary_allocation_ids           = ["eipalloc-0b0bd785601445180", "eipalloc-0e6e93cfd09b860fb"]
  secondary_private_ip_address_count = "0"

  tags = {
    Name = "dsit-llmlite-gateway-main-nat-eu-west-2b"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-nat-eu-west-2b"
  }
}

resource "aws_nat_gateway" "tfer--nat-1766d32e38494d5e2" {
  connectivity_type                  = "public"
  subnet_id                          = data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-08ea423079f9d34de_id
  secondary_allocation_ids           = ["eipalloc-080bcb13b6e9a379a", "eipalloc-0e95cebf2e5b1baa1"]
  secondary_private_ip_address_count = "0"

  tags = {
    Name = "dsit-llmlite-gateway-main-nat-eu-west-2a"
  }

  tags_all = {
    Name = "dsit-llmlite-gateway-main-nat-eu-west-2a"
  }
}
