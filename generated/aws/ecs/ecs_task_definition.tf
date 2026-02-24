resource "aws_ecs_task_definition" "tfer--task-definition-002F-dsit-litellm" {
  container_definitions    = "[{\"environment\":[{\"name\":\"AWS_REGION\",\"value\":\"eu-west-2\"},{\"name\":\"DATABASE_URL\",\"value\":\"postgresql://postgres:litellm2026@dsit-litellm-rds-pg-prod.cluster-ctoyqi6iq1qs.eu-west-2.rds.amazonaws.com:5432/litellm\"},{\"name\":\"LITELLM_MASTER_KEY\",\"value\":\"sk-1234\"},{\"name\":\"STORE_MODEL_IN_DB\",\"value\":\"True\"},{\"name\":\"UI_PASSWORD\",\"value\":\"litellm_admin_2024\"},{\"name\":\"UI_USERNAME\",\"value\":\"admin\"}],\"environmentFiles\":[],\"essential\":true,\"image\":\"072136646002.dkr.ecr.eu-west-2.amazonaws.com/litellm@sha256:6fc76cd6cadd32f51c4a054e892766b093b8463e1a060c3d97c231b50e35e158\",\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"/ecs/\",\"awslogs-create-group\":\"true\",\"awslogs-region\":\"eu-west-2\",\"awslogs-stream-prefix\":\"ecs\"},\"secretOptions\":[]},\"mountPoints\":[],\"name\":\"LIteLLM\",\"portMappings\":[{\"appProtocol\":\"http\",\"containerPort\":4000,\"hostPort\":4000,\"name\":\"litellm-4000-tcp\",\"protocol\":\"tcp\"}],\"systemControls\":[],\"ulimits\":[],\"volumesFrom\":[]}]"
  cpu                      = "1024"
  enable_fault_injection   = "false"
  execution_role_arn       = "arn:aws:iam::072136646002:role/dsit-task-execution-role"
  family                   = "dsit-litellm"
  memory                   = "3072"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  task_role_arn = "arn:aws:iam::072136646002:role/dsit-litellm-fg-bedrock-role"
  track_latest  = "false"
}
