resource "aws_rds_cluster" "tfer--dsit-litellm-rds-pg-prod" {
  allocated_storage                     = "1"
  availability_zones                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  backtrack_window                      = "0"
  backup_retention_period               = "7"
  cluster_identifier                    = "dsit-litellm-rds-pg-prod"
  cluster_members                       = ["dsit-litellm-rds-pg-prod-instance-1", "dsit-litellm-rds-pg-prod-instance-1-eu-west-2b"]
  copy_tags_to_snapshot                 = "true"
  database_insights_mode                = "standard"
  database_name                         = "litellm"
  db_cluster_parameter_group_name       = "default.aurora-postgresql17"
  db_subnet_group_name                  = "${aws_db_subnet_group.tfer--dsit-litellm-rds-pg-subnetgrp.name}"
  deletion_protection                   = "true"
  enable_http_endpoint                  = "true"
  enabled_cloudwatch_logs_exports       = ["iam-db-auth-error", "instance", "postgresql"]
  engine                                = "aurora-postgresql"
  engine_lifecycle_support              = "open-source-rds-extended-support-disabled"
  engine_mode                           = "provisioned"
  engine_version                        = "17.4"
  iam_database_authentication_enabled   = "false"
  iops                                  = "0"
  kms_key_id                            = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  master_username                       = "postgres"
  monitoring_interval                   = "60"
  monitoring_role_arn                   = "arn:aws:iam::072136646002:role/rds-monitoring-role"
  network_type                          = "IPV4"
  performance_insights_enabled          = "true"
  performance_insights_kms_key_id       = "arn:aws:kms:eu-west-2:072136646002:key/9f948df5-5bfe-41fa-9e23-84ff6001f63c"
  performance_insights_retention_period = "7"
  port                                  = "5432"
  preferred_backup_window               = "23:43-00:13"
  preferred_maintenance_window          = "wed:03:11-wed:03:41"

  serverlessv2_scaling_configuration {
    max_capacity             = "8"
    min_capacity             = "0.5"
  }

  storage_encrypted = "true"
  storage_type      = "aurora-iopt1"

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

  vpc_security_group_ids = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-rds-sg_sg-042eb3ca28cbe1b1a_id}"]
}
