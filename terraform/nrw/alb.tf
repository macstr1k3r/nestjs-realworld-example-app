locals {
  alb_dns = "lb.${var.base_domain}"
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "s3_bucket_lb_write" {
  policy_id = "s3_bucket_lb_logs"

  statement {
    actions = [
      "s3:PutObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.nrw_alb_logs.arn}/*",
    ]

    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.nrw_alb_logs.arn}/*"]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }


  statement {
    actions = [
      "s3:GetBucketAcl"
    ]
    effect    = "Allow"
    resources = [aws_s3_bucket.nrw_alb_logs.arn]
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_s3_bucket_policy" "nrw_alb_logs" {
  bucket = aws_s3_bucket.nrw_alb_logs.id
  policy = data.aws_iam_policy_document.s3_bucket_lb_write.json
}

resource "aws_s3_bucket" "nrw_alb_logs" {
  bucket = "nrw-${terraform.workspace}-logs"
  acl    = "log-delivery-write"
}

resource "aws_alb" "nrw_alb" {
  name = "${terraform.workspace}-nrw-ng"

  ip_address_type    = "ipv4"
  load_balancer_type = "application"

  subnets = [for k, v in aws_subnet.nrw_public_subnets : v.id]

  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  security_groups = [aws_security_group.alb_sg.id]

  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.nrw_alb_logs.bucket
    prefix  = "services-alb"
  }

  tags = local.tags.env
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type        = "ingress"
  description = "Allow HTTPS connections to the load balancer"

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type        = "ingress"
  description = "Allow HTTP connections to the load balancer"

  protocol  = "tcp"
  from_port = 80
  to_port   = 80

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_egress" {
  type        = "egress"
  description = "Allow outbound connections from the ALB towards targets in the VPC"

  protocol  = "tcp"
  from_port = 0
  to_port   = 65535

  cidr_blocks       = [aws_vpc.nrw.cidr_block]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group" "alb_sg" {
  name        = "nrw-${terraform.workspace}-alb-ng"
  description = "Load balancer security group, allows incomming traffic & is used as source in the ecs service SGs"

  vpc_id = aws_vpc.nrw.id

  tags = local.tags.env
}

resource "aws_route53_record" "lb_dns" {
  type    = "A"
  name    = local.alb_dns
  zone_id = data.aws_route53_zone.base_zone.zone_id

  alias {
    name                   = aws_alb.nrw_alb.dns_name
    zone_id                = aws_alb.nrw_alb.zone_id
    evaluate_target_health = false
  }
}
