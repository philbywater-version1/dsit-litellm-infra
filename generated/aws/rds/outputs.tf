output "aws_db_instance_tfer--dsit-litellm-rds-pg-prod-instance-1-eu-west-2b_id" {
  value = "${aws_db_instance.tfer--dsit-litellm-rds-pg-prod-instance-1-eu-west-2b.id}"
}

output "aws_db_instance_tfer--dsit-litellm-rds-pg-prod-instance-1_id" {
  value = "${aws_db_instance.tfer--dsit-litellm-rds-pg-prod-instance-1.id}"
}

output "aws_db_subnet_group_tfer--dsit-litellm-rds-pg-subnetgrp_id" {
  value = "${aws_db_subnet_group.tfer--dsit-litellm-rds-pg-subnetgrp.id}"
}

output "aws_rds_cluster_tfer--dsit-litellm-rds-pg-prod_id" {
  value = "${aws_rds_cluster.tfer--dsit-litellm-rds-pg-prod.id}"
}
