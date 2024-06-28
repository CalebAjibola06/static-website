resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = var.calebajibola.me
  type    = "A"
  alias {
    name                   = module.cloudfront.this_cloudfront_domain_name
    zone_id                = module.cloudfront.this_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
