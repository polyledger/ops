resource "aws_route53_delegation_set" "main" {
  reference_name = "DynDNS"
}

resource "aws_route53_zone" "primary_route" {
  name              = "${var.domain}"
  delegation_set_id = "${aws_route53_delegation_set.main.id}"
}

/* Portfolio -> S3/Cloudfront (static assets only) */
resource "aws_route53_record" "portfolio-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "portfolio.${var.domain}"
  type    = "A"

  alias {
    name                    = "${module.cloudfront.cloudfront_domain_name}"
    zone_id                 = "${module.cloudfront.cloudfront_zone_id}"
    evaluate_target_health  = false
  }
}

/* Works for API and admin */
resource "aws_route53_record" "main-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "www.${var.domain}"
  type    = "A"

  alias {
    name                    = "${module.ecs.alb_dns_name}"
    zone_id                 = "${module.ecs.alb_zone_id}"
    evaluate_target_health  = false
  }
}
