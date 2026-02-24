resource "aws_ecs_service" "tfer--dsit-llmlite-gateway-main-cluster-fg_litellm" {
  availability_zone_rebalancing = "ENABLED"

  capacity_provider_strategy {
    base              = "0"
    capacity_provider = "FARGATE"
    weight            = "1"
  }

  cluster = "dsit-llmlite-gateway-main-cluster-fg"

  deployment_circuit_breaker {
    enable   = "true"
    rollback = "true"
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  desired_count                      = "1"
  enable_ecs_managed_tags            = "true"
  enable_execute_command             = "true"
  health_check_grace_period_seconds  = "0"

  load_balancer {
    container_name   = "LIteLLM"
    container_port   = "4000"
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
  }

  name = "litellm"

  network_configuration {
    assign_public_ip = "true"
    security_groups  = ["${data.terraform_remote_state.sg.outputs.aws_security_group_tfer--dsit-llmlite-gateway-main-fargate-sg_sg-07a7dea82a134b0c8_id}"]
    subnets          = ["${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0b9b1a86f2bd6f921_id}", "${data.terraform_remote_state.subnet.outputs.aws_subnet_tfer--subnet-0e8e7db9f4c2f4619_id}"]
  }

  platform_version    = "1.4.0"
  scheduling_strategy = "REPLICA"

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

  task_definition = "arn:aws:ecs:eu-west-2:072136646002:task-definition/dsit-litellm:11"
}
