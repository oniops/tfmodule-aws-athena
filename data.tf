#data "aws_vpc" "this" {
#  filter {
#    name   = "tag:Name"
#    values = ["${local.name_prefix}-vpc"]
#  }
#}
#
#data "aws_subnet_ids" "data" {
#  vpc_id = data.aws_vpc.this.id
#  filter {
#    name   = "tag:Name"
#    values = ["${local.name_prefix}-data-*"]
#  }
#}
#
