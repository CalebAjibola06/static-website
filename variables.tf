variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "calebajibola.me" {
  description = "The domain name for the website"
  type        = string
}

variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID"
  type        = string
}

