resource "aws_route53_record" "app-ng" {
  type    = "A"
  name    = local.app_lb_dns
  zone_id = data.aws_route53_zone.app-ng.zone_id

  alias {
    name                   = data.aws_lb.app-ng.dns_name
    zone_id                = data.aws_lb.app-ng.zone_id
    evaluate_target_health = false
  }
}
