output "aws_lb_listener_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-2a14f6d54dff515d_id" {
  value = "${aws_lb_listener.tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-2a14f6d54dff515d.id}"
}

output "aws_lb_listener_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-6418f1d903d8117a_id" {
  value = "${aws_lb_listener.tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-listener-002F-app-002F-dsit-llmlite-gateway-main-alb-002F-8fde777daec3f125-002F-6418f1d903d8117a.id}"
}

output "aws_lb_target_group_attachment_tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-targetgroup-002F-dsit-litellm-tg-4000-002F-7843fa0003556ddc-10-002E-1-002E-3-002E-128_id" {
  value = "${aws_lb_target_group_attachment.tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-targetgroup-002F-dsit-litellm-tg-4000-002F-7843fa0003556ddc-10-002E-1-002E-3-002E-128.id}"
}

output "aws_lb_target_group_tfer--dsit-litellm-tg-4000_id" {
  value = "${aws_lb_target_group.tfer--dsit-litellm-tg-4000.id}"
}

output "aws_lb_tfer--dsit-llmlite-gateway-main-alb_id" {
  value = "${aws_lb.tfer--dsit-llmlite-gateway-main-alb.id}"
}
