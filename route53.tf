resource "aws_route53_delegation_set" "main" {
  reference_name = "DynDNS"
}

resource "aws_route53_zone" "primary_route" {
  name              = "${var.domain}"
  delegation_set_id = "${aws_route53_delegation_set.main.id}"
}

resource "aws_route53_record" "portfolio-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "portfolio.${var.domain}"
  type    = "A"

  alias {
    name                    = "${module.code_pipeline.frontend_assets_aws_s3_bucket_name}"
    zone_id                 = "${module.code_pipeline.frontend_assets_aws_s3_bucket_zone_id}"
    evaluate_target_health  = true
  }
}

resource "aws_route53_record" "api-prod" {
  zone_id = "${aws_route53_zone.primary_route.id}"
  name    = "api.${var.domain}"
  type    = "A"

  alias {
    name                    = "${module.ecs.alb_dns_name}"
    zone_id                 = "${module.ecs.alb_zone_id}"
    evaluate_target_health  = true
  }
}
