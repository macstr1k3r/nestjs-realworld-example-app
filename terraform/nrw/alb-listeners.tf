data "aws_route53_zone" "base_zone" {
  name = var.base_domain
}

resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "*.${var.base_domain}"
  validation_method = "DNS"

  tags = local.tags.env
}

resource "aws_route53_record" "alb_cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  records = [each.value.record]
  type    = each.value.type
  ttl     = 60
  zone_id = data.aws_route53_zone.base_zone.zone_id

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "alb_cert_validation" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation_records : record.fqdn]
}

resource "aws_alb_listener" "https_listener" {
  port              = 443
  protocol          = "HTTPS"
  load_balancer_arn = aws_alb.nrw_alb.id
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "200"
      content_type = "application/json"
      message_body = "{\"message\":\"Hello\"}"
    }
  }
}

resource "aws_alb_listener" "http_listener" {
  port     = 80
  protocol = "HTTP"

  load_balancer_arn = aws_alb.nrw_alb.id

  # redirect all http requests to https
  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301"
      protocol    = "HTTPS"
      host        = "#{host}"
      path        = "/#{path}"
    }
  }
}
