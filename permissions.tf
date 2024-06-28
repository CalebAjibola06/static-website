resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = module.s3_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${module.s3_bucket.bucket_arn}/*"
      }
    ]
  })
}

module "cloudfront_origin_access_identity" {
  source  = "terraform-aws-modules/cloudfront-origin-access-identity/aws"
  version = "~> 1.0"
}
