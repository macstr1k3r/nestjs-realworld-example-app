locals {
  listener_host_headers = length(var.hostname_settings.prefixes) == 0 ? var.hostname_settings.domains : formatlist("%s.${var.base_domain}", var.hostname_settings.prefixes)
}

resource "aws_lb_target_group" "app-ng" {
  name     = "${terraform.workspace}-${var.product_name}-${var.app.name}-ng"
  vpc_id   = data.aws_vpc.app-ng.id
  protocol = "HTTP"
  port     = var.app.traffic_port


  target_type          = "ip"
  deregistration_delay = 10
  slow_start           = 0

  health_check {
    path                = var.healthcheck_settings.path
    interval            = var.healthcheck_settings.interval
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = floor(var.healthcheck_settings.interval / 2)
    matcher             = "200"
    protocol            = "HTTP"
  }

  tags = local.base_tags
}

resource "aws_lb_listener_rule" "app-ng" {
  listener_arn = var.alb.listener_arn

  condition {
    host_header {
      values = concat(local.listener_host_headers, ["${var.app.name}-lb.${var.base_domain}"])
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-ng.arn
  }
}
