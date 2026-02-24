resource "aws_vpc_endpoint" "tfer--vpce-0258f3643090fa45d" {
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = "true"
  security_group_ids  = ["sg-0e2fac28cbfe8b0a5"]
  service_name        = "com.amazonaws.eu-west-2.ecr.dkr"
  service_region      = "eu-west-2"

  subnet_configuration {
    ipv4      = "10.1.2.111"
    subnet_id = "subnet-0e8e7db9f4c2f4619"
  }

  subnet_configuration {
    ipv4      = "10.1.3.140"
    subnet_id = "subnet-0b9b1a86f2bd6f921"
  }

  subnet_ids        = ["subnet-0b9b1a86f2bd6f921", "subnet-0e8e7db9f4c2f4619"]
  vpc_endpoint_type = "Interface"
  vpc_id            = "vpc-0b5fd89b4223abdc9"
}

resource "aws_vpc_endpoint" "tfer--vpce-059613c618a919e6e" {
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = "true"
  security_group_ids  = ["sg-0e2fac28cbfe8b0a5"]
  service_name        = "com.amazonaws.eu-west-2.bedrock-runtime"
  service_region      = "eu-west-2"

  subnet_configuration {
    ipv4      = "10.1.2.62"
    subnet_id = "subnet-0e8e7db9f4c2f4619"
  }

  subnet_configuration {
    ipv4      = "10.1.3.180"
    subnet_id = "subnet-0b9b1a86f2bd6f921"
  }

  subnet_ids = ["subnet-0b9b1a86f2bd6f921", "subnet-0e8e7db9f4c2f4619"]

  tags = {
    Name = "dsit-litellm-main-bedrock-vpce"
  }

  tags_all = {
    Name = "dsit-litellm-main-bedrock-vpce"
  }

  vpc_endpoint_type = "Interface"
  vpc_id            = "vpc-0b5fd89b4223abdc9"
}

resource "aws_vpc_endpoint" "tfer--vpce-07e5456771b294339" {
  dns_options {
    dns_record_ip_type                             = "service-defined"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}],\"Version\":\"2008-10-17\"}"
  private_dns_enabled = "false"
  route_table_ids     = ["rtb-01741c1b4cfae92c7", "rtb-068d6b7b95412ca2b"]
  service_name        = "com.amazonaws.eu-west-2.s3"
  service_region      = "eu-west-2"
  vpc_endpoint_type   = "Gateway"
  vpc_id              = "vpc-0b5fd89b4223abdc9"
}

resource "aws_vpc_endpoint" "tfer--vpce-08a438b1fc1985a0a" {
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = "true"
  security_group_ids  = ["sg-0e2fac28cbfe8b0a5"]
  service_name        = "com.amazonaws.eu-west-2.logs"
  service_region      = "eu-west-2"

  subnet_configuration {
    ipv4      = "10.1.2.25"
    subnet_id = "subnet-0e8e7db9f4c2f4619"
  }

  subnet_configuration {
    ipv4      = "10.1.3.190"
    subnet_id = "subnet-0b9b1a86f2bd6f921"
  }

  subnet_ids        = ["subnet-0b9b1a86f2bd6f921", "subnet-0e8e7db9f4c2f4619"]
  vpc_endpoint_type = "Interface"
  vpc_id            = "vpc-0b5fd89b4223abdc9"
}

resource "aws_vpc_endpoint" "tfer--vpce-0a56e590698c7bddb" {
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = "true"
  security_group_ids  = ["sg-0e2fac28cbfe8b0a5"]
  service_name        = "com.amazonaws.eu-west-2.ecr.api"
  service_region      = "eu-west-2"

  subnet_configuration {
    ipv4      = "10.1.2.209"
    subnet_id = "subnet-0e8e7db9f4c2f4619"
  }

  subnet_configuration {
    ipv4      = "10.1.3.20"
    subnet_id = "subnet-0b9b1a86f2bd6f921"
  }

  subnet_ids        = ["subnet-0b9b1a86f2bd6f921", "subnet-0e8e7db9f4c2f4619"]
  vpc_endpoint_type = "Interface"
  vpc_id            = "vpc-0b5fd89b4223abdc9"
}

resource "aws_vpc_endpoint" "tfer--vpce-0e3287eb665157079" {
  dns_options {
    dns_record_ip_type                             = "ipv4"
    private_dns_only_for_inbound_resolver_endpoint = "false"
  }

  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = "true"
  security_group_ids  = ["sg-0e2fac28cbfe8b0a5"]
  service_name        = "com.amazonaws.eu-west-2.secretsmanager"
  service_region      = "eu-west-2"

  subnet_configuration {
    ipv4      = "10.1.2.150"
    subnet_id = "subnet-0e8e7db9f4c2f4619"
  }

  subnet_configuration {
    ipv4      = "10.1.3.81"
    subnet_id = "subnet-0b9b1a86f2bd6f921"
  }

  subnet_ids        = ["subnet-0b9b1a86f2bd6f921", "subnet-0e8e7db9f4c2f4619"]
  vpc_endpoint_type = "Interface"
  vpc_id            = "vpc-0b5fd89b4223abdc9"
}
