resource "aws_ecs_cluster" "tfer--dsit-llmlite-gateway-main-cluster-fg" {
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  name = "dsit-llmlite-gateway-main-cluster-fg"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-cluster-fg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Description  = "AI Engineering Lab"
    Name         = "dsit-llmlite-gateway-main-cluster-fg"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}
