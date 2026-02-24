resource "aws_db_subnet_group" "tfer--dsit-litellm-rds-pg-subnetgrp" {
  description = "The RDS Aurora Subnet Group that references the Database subnets in eu-west-2s and eu-wes-2b"
  name        = "dsit-litellm-rds-pg-subnetgrp"
  subnet_ids  = ["${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-052358aaa1ec9d954_id}", "${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0c8c3706a833bcb6f_id}"]
}
