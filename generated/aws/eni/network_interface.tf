resource "aws_network_interface" "tfer--eni-00bcbc0a7881b9bae" {
  description        = "arn:aws:ecs:eu-west-2:072136646002:attachment/5dd9ffd4-fc22-4a7d-9fe9-9b8ed094fc40"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "172.31.45.28"
  private_ip_list    = ["172.31.45.28"]
  private_ips        = ["172.31.45.28"]
  private_ips_count  = "0"
  security_groups    = ["sg-03450ee9250362c61"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0d5eec6111a7a8e09"
}

resource "aws_network_interface" "tfer--eni-01089bf07df545003" {
  description        = "VPC Endpoint Interface vpce-0a56e590698c7bddb"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.20"
  private_ip_list    = ["10.1.3.20"]
  private_ips        = ["10.1.3.20"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-0232271753c7cf223" {
  description        = "ELB app/dsit-llmlite-gateway-main-alb/8fde777daec3f125"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.0.169"
  private_ip_list    = ["10.1.0.169"]
  private_ips        = ["10.1.0.169"]
  private_ips_count  = "0"
  security_groups    = ["sg-0d57a68abe5cdaba4"]
  source_dest_check  = "true"
  subnet_id          = "subnet-08ea423079f9d34de"
}

resource "aws_network_interface" "tfer--eni-0270781b4b3275478" {
  description        = "EFS mount target for fs-07d88ce82597e73c4 (fsmt-0ec32308d86b14dba)"
  interface_type     = "efs"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.1.107"
  private_ip_list    = ["10.1.1.107"]
  private_ips        = ["10.1.1.107"]
  private_ips_count  = "0"
  security_groups    = ["sg-032b5d79b1050a33e"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0310f584f58ff14b6"
}

resource "aws_network_interface" "tfer--eni-04791b284d5fa8b73" {
  description        = "arn:aws:ecs:eu-west-2:072136646002:attachment/e0d09042-2dab-4b60-8e7f-7b6539ac2377"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.128"
  private_ip_list    = ["10.1.3.128"]
  private_ips        = ["10.1.3.128"]
  private_ips_count  = "0"
  security_groups    = ["sg-07a7dea82a134b0c8"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-0488499498d66be44" {
  description        = "VPC Endpoint Interface vpce-059613c618a919e6e"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.180"
  private_ip_list    = ["10.1.3.180"]
  private_ips        = ["10.1.3.180"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-0633626942f51e556" {
  description        = "VPC Endpoint Interface vpce-0258f3643090fa45d"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.140"
  private_ip_list    = ["10.1.3.140"]
  private_ips        = ["10.1.3.140"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-06852c8da541075c9" {
  description        = "VPC Endpoint Interface vpce-0a56e590698c7bddb"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.2.209"
  private_ip_list    = ["10.1.2.209"]
  private_ips        = ["10.1.2.209"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0e8e7db9f4c2f4619"
}

resource "aws_network_interface" "tfer--eni-07885512fac191f77" {
  description        = "VPC Endpoint Interface vpce-08a438b1fc1985a0a"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.2.25"
  private_ip_list    = ["10.1.2.25"]
  private_ips        = ["10.1.2.25"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0e8e7db9f4c2f4619"
}

resource "aws_network_interface" "tfer--eni-07f98dc4d2a7b9abd" {
  description        = "RDSNetworkInterface"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.5.45"
  private_ip_list    = ["10.1.5.45"]
  private_ips        = ["10.1.5.45"]
  private_ips_count  = "0"
  security_groups    = ["sg-042eb3ca28cbe1b1a"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0c8c3706a833bcb6f"
}

resource "aws_network_interface" "tfer--eni-08d52829c9206a081" {
  description        = "VPC Endpoint Interface vpce-0e3287eb665157079"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.2.150"
  private_ip_list    = ["10.1.2.150"]
  private_ips        = ["10.1.2.150"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0e8e7db9f4c2f4619"
}

resource "aws_network_interface" "tfer--eni-09c7469623204e6d2" {
  description        = "VPC Endpoint Interface vpce-0e3287eb665157079"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.81"
  private_ip_list    = ["10.1.3.81"]
  private_ips        = ["10.1.3.81"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-0a5f8880970be54d3" {
  description        = "VPC Endpoint Interface vpce-0258f3643090fa45d"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.2.111"
  private_ip_list    = ["10.1.2.111"]
  private_ips        = ["10.1.2.111"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0e8e7db9f4c2f4619"
}

resource "aws_network_interface" "tfer--eni-0affc60df64fef052" {
  description        = "RDSNetworkInterface"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.4.117"
  private_ip_list    = ["10.1.4.117"]
  private_ips        = ["10.1.4.117"]
  private_ips_count  = "0"
  security_groups    = ["sg-042eb3ca28cbe1b1a"]
  source_dest_check  = "true"
  subnet_id          = "subnet-052358aaa1ec9d954"
}

resource "aws_network_interface" "tfer--eni-0ebed66f76567dbcf" {
  description        = "ELB app/dsit-llmlite-gateway-main-alb/8fde777daec3f125"
  interface_type     = "interface"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.1.34"
  private_ip_list    = ["10.1.1.34"]
  private_ips        = ["10.1.1.34"]
  private_ips_count  = "0"
  security_groups    = ["sg-0d57a68abe5cdaba4"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0310f584f58ff14b6"
}

resource "aws_network_interface" "tfer--eni-0f12788fdc660438d" {
  description        = "EFS mount target for fs-07d88ce82597e73c4 (fsmt-0fcc59c561c097e09)"
  interface_type     = "efs"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.4.136"
  private_ip_list    = ["10.1.4.136"]
  private_ips        = ["10.1.4.136"]
  private_ips_count  = "0"
  security_groups    = ["sg-032b5d79b1050a33e"]
  source_dest_check  = "true"
  subnet_id          = "subnet-052358aaa1ec9d954"
}

resource "aws_network_interface" "tfer--eni-0f397a57ff4ed679a" {
  description        = "VPC Endpoint Interface vpce-08a438b1fc1985a0a"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.3.190"
  private_ip_list    = ["10.1.3.190"]
  private_ips        = ["10.1.3.190"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0b9b1a86f2bd6f921"
}

resource "aws_network_interface" "tfer--eni-0fc6527a383796436" {
  description        = "VPC Endpoint Interface vpce-059613c618a919e6e"
  interface_type     = "vpc_endpoint"
  ipv4_prefix_count  = "0"
  ipv6_address_count = "0"
  ipv6_prefix_count  = "0"
  private_ip         = "10.1.2.62"
  private_ip_list    = ["10.1.2.62"]
  private_ips        = ["10.1.2.62"]
  private_ips_count  = "0"
  security_groups    = ["sg-0e2fac28cbfe8b0a5"]
  source_dest_check  = "true"
  subnet_id          = "subnet-0e8e7db9f4c2f4619"
}
