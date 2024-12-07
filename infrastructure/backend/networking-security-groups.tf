resource "aws_security_group" "app_sg" {
    name = "app_sg"
    description = "security group for application tier"
    vpc_id = data.aws_vpc.selected.id
    revoke_rules_on_delete = true

    tags = {
        Name = "app_sg"
        managed-by = "terraform"
    }

}

resource "aws_vpc_security_group_egress_rule" "app_sg_outbound" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow All Outbound Traffic"
}


resource "aws_security_group" "data_sg" {
    name = "data_sg"
    description = "custom security group for data tier."
    vpc_id = data.aws_vpc.selected.id
    revoke_rules_on_delete = true
    tags = {
        Name = "data_sg"
        managed-by = "terraform"
    }
}

resource "aws_vpc_security_group_ingress_rule" "data_sg_east_west" {
  security_group_id = aws_security_group.data_sg.id
  referenced_security_group_id = aws_security_group.data_sg.id
  ip_protocol = "-1"
  description = "East/West Communication within Data Security Group."
}

resource "aws_vpc_security_group_ingress_rule" "data_sg_postgres" {
  security_group_id = aws_security_group.data_sg.id
  referenced_security_group_id = aws_security_group.app_sg.id
  from_port = 5432
  to_port = 5432
  ip_protocol = "TCP"
  description = "Allow traffic to database from application tier."
}

resource "aws_vpc_security_group_egress_rule" "data_sg_outbound" {
  security_group_id = aws_security_group.data_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow All Outbound Traffic"
}