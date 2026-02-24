resource "aws_lb_listener" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-2a14f6d54dff515d" {
  default_action {
    forward {
      stickiness {
        duration = "3600"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
        weight = "1"
      }
    }

    order            = "1"
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
    type             = "forward"
  }

  load_balancer_arn                    = "${data.terraform_remote_state.alb.outputs.aws_lb_tfer--dsit-llmlite-gateway-main-alb_id}"
  port                                 = "80"
  protocol                             = "HTTP"
  routing_http_response_server_enabled = "true"
}

resource "aws_lb_listener" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-6418f1d903d8117a" {
  certificate_arn = "arn:aws:acm:eu-west-2:072136646002:certificate/ba9e8dc1-8a27-4bd6-a616-7bb496bc0ebf"

  default_action {
    forward {
      stickiness {
        duration = "3600"
        enabled  = "false"
      }

      target_group {
        arn    = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
        weight = "1"
      }
    }

    order            = "1"
    target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
    type             = "forward"
  }

  load_balancer_arn = "${data.terraform_remote_state.alb.outputs.aws_lb_tfer--dsit-llmlite-gateway-main-alb_id}"

  mutual_authentication {
    ignore_client_certificate_expiry = "false"
    mode                             = "off"
  }

  port                                 = "443"
  protocol                             = "HTTPS"
  routing_http_response_server_enabled = "true"
  ssl_policy                           = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
}
