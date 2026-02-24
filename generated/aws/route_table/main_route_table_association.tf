resource "aws_main_route_table_association" "tfer--vpc-0b5fd89b4223abdc9" {
  route_table_id = "${data.terraform_remote_state.route_table.outputs.aws_route_table_tfer--rtb-0b95cb5d7ddee8676_id}"
  vpc_id         = "${data.terraform_remote_state.vpc.outputs.aws_vpc_tfer--vpc-0b5fd89b4223abdc9_id}"
}
