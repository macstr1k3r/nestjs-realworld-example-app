resource "aws_security_group_rule" "app-ng" {
  type        = "ingress"
  description = "Allow the load balancer to access this service"

  protocol  = "tcp"
  from_port = var.app.traffic_port
  to_port   = var.app.traffic_port

  source_security_group_id = var.alb.sg_id
  security_group_id        = aws_security_group.app-ng.id
}

resource "aws_security_group_rule" "app-egress" {
  type        = "egress"
  description = "Allow the service to do stuff"

  protocol  = "tcp"
  from_port = 0
  to_port   = 65535

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app-ng.id
}

resource "aws_security_group" "app-ng" {
  name        = "${terraform.workspace}-${var.app.name}-sg"
  description = "Security group for the service, allowing lb access and outbound traffic"

  vpc_id = data.aws_vpc.app-ng.id

  tags = local.base_tags
}
