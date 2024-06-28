module "s3_bucket" {
  source              = "terraform-aws-modules/s3-bucket/aws"
  version             = "~> 1.0"
  bucket              = var.s3_bucket_name
  acl                 = "public-read"
  website             = {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags                = {
    Name        = "s3-static-website"
    Environment = var.environment
  }
}
