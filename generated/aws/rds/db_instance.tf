resource "aws_db_instance" "tfer--dsit-litellm-rds-pg-prod-instance-1" {
  allocated_storage                     = "1"
  auto_minor_version_upgrade            = "true"
  availability_zone                     = "eu-west-2a"
  backup_retention_period               = "7"
  backup_target                         = "region"
  backup_window                         = "23:43-00:13"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot                 = "false"
  customer_owned_ip_enabled             = "false"
  database_insights_mode                = "standard"
  db_name                               = "litellm"
  db_subnet_group_name                  = "${aws_db_subnet_group.tfer--dsit-litellm-rds-pg-subnetgrp.name}"
  dedicated_log_volume                  = "false"
  deletion_protection                   = "false"
  enabled_cloudwatch_logs_exports       = ["iam-db-auth-error", "postgresql"]
  engine                                = "aurora-postgresql"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  engine_version                        = "17.4"
  iam_database_authentication_enabled   = "false"
  identifier                            = "dsit-litellm-rds-pg-prod-instance-1"
  instance_class                        = "db.serverless"
  iops                                  = "0"
  kms_key_id                            = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  license_model                         = "postgresql-license"
  maintenance_window                    = "sat:22:28-sat:22:58"
  max_allocated_storage                 = "0"
  monitoring_interval                   = "60"
  monitoring_role_arn                   = "arn:aws:iam::072136646002:role/rds-monitoring-role"
  multi_az                              = "false"
  network_type                          = "IPV4"
  option_group_name                     = "default:aurora-postgresql-17"
  parameter_group_name                  = "default.aurora-postgresql17"
  performance_insights_enabled          = "true"
  performance_insights_kms_key_id       = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  performance_insights_retention_period = "7"
  port                                  = "5432"
  publicly_accessible                   = "false"
  storage_encrypted                     = "true"
  storage_throughput                    = "0"
  storage_type                          = "aurora-iopt1"

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

  username               = "postgres"
  vpc_security_group_ids = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-rds-sg_sg-042eb3ca28cbe1b1a_id}"]
}

resource "aws_db_instance" "tfer--dsit-litellm-rds-pg-prod-instance-1-eu-west-2b" {
  allocated_storage                     = "1"
  auto_minor_version_upgrade            = "true"
  availability_zone                     = "eu-west-2b"
  backup_retention_period               = "7"
  backup_target                         = "region"
  backup_window                         = "23:43-00:13"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  copy_tags_to_snapshot                 = "false"
  customer_owned_ip_enabled             = "false"
  database_insights_mode                = "standard"
  db_name                               = "litellm"
  db_subnet_group_name                  = "${aws_db_subnet_group.tfer--dsit-litellm-rds-pg-subnetgrp.name}"
  dedicated_log_volume                  = "false"
  deletion_protection                   = "false"
  enabled_cloudwatch_logs_exports       = ["iam-db-auth-error", "postgresql"]
  engine                                = "aurora-postgresql"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  engine_version                        = "17.4"
  iam_database_authentication_enabled   = "false"
  identifier                            = "dsit-litellm-rds-pg-prod-instance-1-eu-west-2b"
  instance_class                        = "db.serverless"
  iops                                  = "0"
  kms_key_id                            = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  license_model                         = "postgresql-license"
  maintenance_window                    = "sat:02:56-sat:03:26"
  max_allocated_storage                 = "0"
  monitoring_interval                   = "60"
  monitoring_role_arn                   = "arn:aws:iam::072136646002:role/rds-monitoring-role"
  multi_az                              = "false"
  network_type                          = "IPV4"
  option_group_name                     = "default:aurora-postgresql-17"
  parameter_group_name                  = "default.aurora-postgresql17"
  performance_insights_enabled          = "true"
  performance_insights_kms_key_id       = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  performance_insights_retention_period = "7"
  port                                  = "5432"
  publicly_accessible                   = "false"
  storage_encrypted                     = "true"
  storage_throughput                    = "0"
  storage_type                          = "aurora-iopt1"

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

  username               = "postgres"
  vpc_security_group_ids = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-rds-sg_sg-042eb3ca28cbe1b1a_id}"]
}
