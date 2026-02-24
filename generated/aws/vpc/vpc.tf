resource "aws_vpc" "tfer--vpc-0b5fd89b4223abdc9" {
  assign_generated_ipv6_cidr_block     = "false"
  cidr_block                           = "10.1.0.0/20"
  enable_dns_hostnames                 = "true"
  enable_dns_support                   = "true"
  enable_network_address_usage_metrics = "false"
  instance_tenancy                     = "default"


  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}
