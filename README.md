Deploy a Static Website on AWS using Terraform
Objective
Create an AWS infrastructure to host a static website using Terraform. The infrastructure includes AWS S3 for storing the website files, CloudFront for content delivery, and Route 53 for domain name management. Additional configurations involve setting up IAM roles and policies, API Gateway, and SSL certificates.

Prerequisites
AWS Account
Domain name registered in Route 53 (e.g., calebajibola.me)
File Structure
csharp
Copy code
├── api_gateway_config.tf
├── api_gateway_resources.tf
├── certificate.tf
├── data.tf
├── init.tf
├── main.tf
├── outputs.tf
├── permissions.tf
├── README.md
├── route53.tf
├── variables.tf
└── s3-static-website.png
Files Description:

api_gateway_config.tf: Configuration for API Gateway.
api_gateway_resources.tf: API Gateway resources definition.
certificate.tf: SSL certificate configuration.
data.tf: Data sources for Terraform.
init.tf: Initialization configuration for Terraform.
main.tf: Main infrastructure setup.
outputs.tf: Outputs for Terraform.
permissions.tf: IAM roles and policies.
README.md: Project documentation.
route53.tf: Route 53 DNS configuration.
variables.tf: Variables used in the Terraform project.
s3-static-website.png: Diagram of the infrastructure.
Step-by-Step Instructions
Step 1: Initialize the Terraform Project
Create a new directory for your Terraform project.
Create the files according to the file structure mentioned above.
In your terminal, navigate to the project directory and run:
sh
Copy code
terraform init
This command initializes the project and downloads the necessary providers and modules.

Step 2: Configure AWS S3 Bucket
Create a new file s3.tf to define the S3 bucket module:
hcl
Copy code
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
Define the variables in variables.tf:
hcl
Copy code
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}
Define the bucket policy in permissions.tf:
hcl
Copy code
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
Step 3: Set Up CloudFront Distribution
Create a new file cloudfront.tf to define the CloudFront distribution module:
hcl
Copy code
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
Define the variables in variables.tf:
hcl
Copy code
variable "domain_name" {
  description = "The domain name for the website"
  type        = string
}
Define the CloudFront origin access identity in permissions.tf:
hcl
Copy code
module "cloudfront_origin_access_identity" {
  source  = "terraform-aws-modules/cloudfront-origin-access-identity/aws"
  version = "~> 1.0"
}
Step 4: Manage Domain with Route 53
Create a new file route53.tf to define Route 53 configuration:
hcl
Copy code
resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.cloudfront.this_cloudfront_domain_name
    zone_id                = module.cloudfront.this_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
Define the variables in variables.tf:
hcl
Copy code
variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID"
  type        = string
}
Step 5: Security and Access Management
Define IAM roles and policies in permissions.tf to secure the S3 bucket and CloudFront distribution.
Step 6: API Gateway Configuration
Define API Gateway configuration in api_gateway_config.tf.
Define necessary resources and methods in api_gateway_resources.tf.
Step 7: SSL Certificate Configuration
Create a new file certificate.tf to request and validate an SSL certificate using ACM:
hcl
Copy code
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "s3-static-website"
    Environment = var.environment
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
Step 8: Deployment and Testing
Run terraform apply to deploy the infrastructure:
sh
Copy code
terraform apply
Verify the deployment by accessing the website via the custom domain calebajibola.me.
Verification
To verify that the website is up and running, open a web browser and navigate to calebajibola.me. You should see your static website being served from the S3 bucket through the CloudFront distribution with the domain managed by Route 53.

By following these steps, you will have a fully functional static website hosted on AWS using Terraform.





Deploy a Static Website on AWS using Terraform
Objective
Create an AWS infrastructure to host a static website using Terraform. The infrastructure includes AWS S3 for storing the website files, CloudFront for content delivery, and Route 53 for domain name management. Additional configurations involve setting up IAM roles and policies, API Gateway, and SSL certificates.

Prerequisites
AWS Account
Domain name registered in Route 53 (e.g., calebajibola.me)
File Structure
csharp
Copy code
├── api_gateway_config.tf
├── api_gateway_resources.tf
├── certificate.tf
├── data.tf
├── init.tf
├── main.tf
├── outputs.tf
├── permissions.tf
├── README.md
├── route53.tf
├── variables.tf
└── s3-static-website.png
Files Description:

api_gateway_config.tf: Configuration for API Gateway.
api_gateway_resources.tf: API Gateway resources definition.
certificate.tf: SSL certificate configuration.
data.tf: Data sources for Terraform.
init.tf: Initialization configuration for Terraform.
main.tf: Main infrastructure setup.
outputs.tf: Outputs for Terraform.
permissions.tf: IAM roles and policies.
README.md: Project documentation.
route53.tf: Route 53 DNS configuration.
variables.tf: Variables used in the Terraform project.
s3-static-website.png: Diagram of the infrastructure.
Step-by-Step Instructions
Step 1: Initialize the Terraform Project
Create a new directory for your Terraform project.
Create the files according to the file structure mentioned above.
In your terminal, navigate to the project directory and run:
sh
Copy code
terraform init
This command initializes the project and downloads the necessary providers and modules.

Step 2: Configure AWS S3 Bucket
Create a new file s3.tf to define the S3 bucket module:
hcl
Copy code
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
Define the variables in variables.tf:
hcl
Copy code
variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}
Define the bucket policy in permissions.tf:
hcl
Copy code
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
Step 3: Set Up CloudFront Distribution
Create a new file cloudfront.tf to define the CloudFront distribution module:
hcl
Copy code
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
Define the variables in variables.tf:
hcl
Copy code
variable "domain_name" {
  description = "The domain name for the website"
  type        = string
}
Define the CloudFront origin access identity in permissions.tf:
hcl
Copy code
module "cloudfront_origin_access_identity" {
  source  = "terraform-aws-modules/cloudfront-origin-access-identity/aws"
  version = "~> 1.0"
}
Step 4: Manage Domain with Route 53
Create a new file route53.tf to define Route 53 configuration:
hcl
Copy code
resource "aws_route53_record" "www" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.cloudfront.this_cloudfront_domain_name
    zone_id                = module.cloudfront.this_cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}
Define the variables in variables.tf:
hcl
Copy code
variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID"
  type        = string
}
Step 5: Security and Access Management
Define IAM roles and policies in permissions.tf to secure the S3 bucket and CloudFront distribution.
Step 6: API Gateway Configuration
Define API Gateway configuration in api_gateway_config.tf.
Define necessary resources and methods in api_gateway_resources.tf.
Step 7: SSL Certificate Configuration
Create a new file certificate.tf to request and validate an SSL certificate using ACM:
hcl
Copy code
resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "s3-static-website"
    Environment = var.environment
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
Step 8: Deployment and Testing
Run terraform apply to deploy the infrastructure:
sh
Copy code
terraform apply
Verify the deployment by accessing the website via the custom domain calebajibola.me.
Verification
To verify that the website is up and running, open a web browser and navigate to calebajibola.me. You should see your static website being served from the S3 bucket through the CloudFront distribution with the domain managed by Route 53.

By following these steps, you will have a fully functional static website hosted on AWS using Terraform.





