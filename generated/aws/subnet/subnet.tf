resource "aws_subnet" "tfer--subnet-0310f584f58ff14b6" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.1.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "true"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-public-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-public-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_subnet" "tfer--subnet-052358aaa1ec9d954" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.4.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-database-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-database-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_subnet" "tfer--subnet-08ea423079f9d34de" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.0.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "true"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-public-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-public-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_subnet" "tfer--subnet-0b9b1a86f2bd6f921" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.3.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_subnet" "tfer--subnet-0c8c3706a833bcb6f" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.5.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-database-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-database-eu-west-2b"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}

resource "aws_subnet" "tfer--subnet-0e8e7db9f4c2f4619" {
  assign_ipv6_address_on_creation                = "false"
  cidr_block                                     = "10.1.2.0/24"
  enable_dns64                                   = "false"
  enable_lni_at_device_index                     = "0"
  enable_resource_name_dns_a_record_on_launch    = "false"
  enable_resource_name_dns_aaaa_record_on_launch = "false"
  ipv6_native                                    = "false"
  map_customer_owned_ip_on_launch                = "false"
  map_public_ip_on_launch                        = "false"
  private_dns_hostname_type_on_launch            = "ip-name"

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-private-eu-west-2a"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  vpc_id = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}
