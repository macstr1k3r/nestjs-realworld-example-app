locals {
  app_lb_dns = "${var.app.name}-lb.${var.base_domain}"
  base_tags = {
    "${var.product_name}:env" : terraform.workspace
  }
}

data "aws_region" "app-ng" {}

data "aws_subnet" "app-ng" { # used as an intermediary to get the vpc
  id = var.app.subnet_ids[0]
}

data "aws_vpc" "app-ng" {
  id = data.aws_subnet.app-ng.vpc_id
}

data "aws_lb" "app-ng" {
  arn = var.alb.id
}

data "aws_route53_zone" "app-ng" {
  name = var.base_domain
}
