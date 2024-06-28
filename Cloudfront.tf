module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 1.0"

  aliases = [var.domain_name]

  default_cache_behavior = {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  }

  origins = [
    {
      domain_name = module.s3_bucket.bucket_regional_domain_name
      origin_id   = "S3Origin"
      s3_origin_config = {
        origin_access_identity = module.cloudfront_origin_access_identity.this_cloudfront_origin_access_identity_id
      }
    }
  ]

  viewer_certificate = {
    acm_certificate_arn            = aws_acm_certificate.this.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2018"
  }
}
