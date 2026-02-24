resource "aws_wafv2_web_acl_logging_configuration" "tfer--arn-003A-aws-003A-wafv2-003A-eu-west-2-003A-072136646002-003A-regional-002F-webacl-002F-dsit-litellm-main-alb-waf-002F-d5c33f20-93de-4ea0-b19c-15aacf188f08" {
  log_destination_configs = ["arn:aws:logs:eu-west-2:072136646002:log-group:aws-waf-logs-dsit-litellm-prod"]
  resource_arn            = "arn:aws:wafv2:eu-west-2:072136646002:regional/webacl/dsit-litellm-main-alb-waf/d5c33f20-93de-4ea0-b19c-15aacf188f08"
}
