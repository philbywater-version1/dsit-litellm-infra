output "aws_ecs_cluster_tfer--dsit-llmlite-gateway-main-cluster-fg_id" {
  value = "${aws_ecs_cluster.tfer--dsit-llmlite-gateway-main-cluster-fg.id}"
}

output "aws_ecs_service_tfer--dsit-llmlite-gateway-main-cluster-fg_litellm_id" {
  value = "${aws_ecs_service.tfer--dsit-llmlite-gateway-main-cluster-fg_litellm.id}"
}

output "aws_ecs_task_definition_tfer--task-definition-002F-dsit-litellm_id" {
  value = "${aws_ecs_task_definition.tfer--task-definition-002F-dsit-litellm.id}"
}
