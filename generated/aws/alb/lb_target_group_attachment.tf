resource "aws_lb_target_group_attachment" "tfer--arn-003A-aws-003A-elasticloadbalancing-003A-eu-west-2-003A-072136646002-003A-targetgroup-002F-dsit-litellm-tg-4000-002F-7843fa0003556ddc-10-002E-1-002E-3-002E-128" {
  target_group_arn = "arn:aws:elasticloadbalancing:eu-west-2:072136646002:targetgroup/dsit-litellm-tg-4000/7843fa0003556ddc"
  target_id        = "10.1.3.128"
}
