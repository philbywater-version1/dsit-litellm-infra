resource "aws_lb" "tfer--dsit-llmlite-gateway-main-alb" {
  client_keep_alive = "3600"

  connection_logs {
    enabled = "false"
  }

  desync_mitigation_mode                      = "defensive"
  drop_invalid_header_fields                  = "false"
  enable_cross_zone_load_balancing            = "true"
  enable_deletion_protection                  = "false"
  enable_http2                                = "true"
  enable_tls_version_and_cipher_suite_headers = "false"
  enable_waf_fail_open                        = "false"
  enable_xff_client_port                      = "false"
  enable_zonal_shift                          = "false"
  idle_timeout                                = "60"
  internal                                    = "false"
  ip_address_type                             = "ipv4"
  load_balancer_type                          = "application"
  name                                        = "dsit-llmlite-gateway-main-alb"
  preserve_host_header                        = "false"
  security_groups                             = ["sg-0d57a68abe5cdaba4"]

  subnet_mapping {
    subnet_id = "subnet-0310f584f58ff14b6"
  }

  subnet_mapping {
    subnet_id = "subnet-08ea423079f9d34de"
  }

  subnets = ["${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0310f584f58ff14b6_id}", "${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-08ea423079f9d34de_id}"]

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

  xff_header_processing_mode = "append"
}
