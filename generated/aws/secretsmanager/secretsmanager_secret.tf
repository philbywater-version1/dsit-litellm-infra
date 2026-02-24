resource "aws_secretsmanager_secret" "tfer--litellm-002F-bedrock-002F-api" {
  description = "The API key and other metadata to integrate Amazon Bedrock with LiteLLM"
  name        = "litellm/bedrock/api"

  tags = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}

resource "aws_secretsmanager_secret" "tfer--litellm-002F-masterkey" {
  description = "The API key used to connect to the LiteLLM REST Api"
  name        = "litellm/masterkey"

  tags = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}

resource "aws_secretsmanager_secret" "tfer--litellm-002F-ui-002F-creds" {
  description = "The username and password to access the LiteLLM Admin UI forms"
  name        = "litellm/ui/creds"

  tags = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }

  tags_all = {
    Application  = "LiteLLM"
    Description  = "AI Engineering Lab"
    Organisation = "DSIT"
    Title        = "AIEL"
  }
}

resource "aws_secretsmanager_secret" "tfer--rds-db-credentials-002F-cluster-7B532B6S3LSCGGTRF6EXATSHM4-002F-postgres-002F-1771316927093" {
  description = "RDS database postgres credentials for dsit-litellm-rds-pg"
  name        = "rds-db-credentials/cluster-7B532B6S3LSCGGTRF6EXATSHM4/postgres/1771316927093"

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
}

resource "aws_secretsmanager_secret" "tfer--rds-db-credentials-002F-cluster-OBWW5573LDKZCS477Y7OM3H25U-002F-postgres-002F-1771321958569" {
  description = "RDS database postgres credentials for dsit-litellm-rds-pg-prod"
  name        = "rds-db-credentials/cluster-OBWW5573LDKZCS477Y7OM3H25U/postgres/1771321958569"

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
}

resource "aws_secretsmanager_secret" "tfer--rds-db-credentials-002F-cluster-OBWW5573LDKZCS477Y7OM3H25U-002F-postgres-002F-1771321998887" {
  description = "RDS database postgres credentials for dsit-litellm-rds-pg-prod"
  name        = "rds-db-credentials/cluster-OBWW5573LDKZCS477Y7OM3H25U/postgres/1771321998887"

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
}
