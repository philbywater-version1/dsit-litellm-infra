output "aws_iam_role_tfer--dsit-litellm-fg-bedrock-role_id" {
  value = "${aws_iam_role.tfer--dsit-litellm-fg-bedrock-role.id}"
}

output "aws_iam_role_tfer--dsit-litellm-gateway-main-task-admin_id" {
  value = "${aws_iam_role.tfer--dsit-litellm-gateway-main-task-admin.id}"
}

output "aws_iam_role_tfer--dsit-litellm-gateway-main-task-execution-role_id" {
  value = "${aws_iam_role.tfer--dsit-litellm-gateway-main-task-execution-role.id}"
}

output "aws_iam_role_tfer--dsit-task-execution-role_id" {
  value = "${aws_iam_role.tfer--dsit-task-execution-role.id}"
}
