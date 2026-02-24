resource "aws_wafv2_web_acl" "tfer--dsit-litellm-main-alb-waf_d5c33f20" {
  description = "Web application firewall for the application load balancer."
  name        = "dsit-litellm-main-alb-waf"

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = "2"

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = "true"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = "0"

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesCommonRuleSet"

        rule_action_override {
          name = "CrossSiteScripting_BODY"
        }

        rule_action_override {
          name = "CrossSiteScripting_COOKIE"
        }

        rule_action_override {
          name = "CrossSiteScripting_QUERYARGUMENTS"
        }

        rule_action_override {
          name = "CrossSiteScripting_URIPATH"
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_BODY"
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_COOKIE"
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_QUERYARGUMENTS"
        }

        rule_action_override {
          name = "EC2MetaDataSSRF_URIPATH"
        }

        rule_action_override {
          name = "GenericLFI_BODY"
        }

        rule_action_override {
          name = "GenericLFI_QUERYARGUMENTS"
        }

        rule_action_override {
          name = "GenericLFI_URIPATH"
        }

        rule_action_override {
          name = "GenericRFI_BODY"
        }

        rule_action_override {
          name = "GenericRFI_QUERYARGUMENTS"
        }

        rule_action_override {
          name = "GenericRFI_URIPATH"
        }

        rule_action_override {
          name = "NoUserAgent_HEADER"
        }

        rule_action_override {
          name = "RestrictedExtensions_QUERYARGUMENTS"
        }

        rule_action_override {
          name = "RestrictedExtensions_URIPATH"
        }

        rule_action_override {
          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          name = "SizeRestrictions_Cookie_HEADER"
        }

        rule_action_override {
          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          name = "SizeRestrictions_URIPATH"
        }

        rule_action_override {
          name = "UserAgent_BadBots_HEADER"
        }

        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = "true"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = "1"

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = "true"
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = "3"

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = "true"
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = "true"
    }
  }

  scope = "REGIONAL"

  visibility_config {
    cloudwatch_metrics_enabled = "true"
    metric_name                = "dsit-litellm-main-alb-waf"
    sampled_requests_enabled   = "true"
  }
}
