provider "aws" {
    region = "ca-central-1"
}

#===============================================================================================================
#   S3 STORAGE CONFIGURATION
#===============================================================================================================

# Create a Bucket 
resource "aws_s3_bucket" "S3Bucket" {
    bucket = "static-website-portfolio-client"

    tags = {
        Name = "Bucket-Static-Website"
    }
}

#Block Public Access to the bucket
resource "aws_s3_bucket_public_access_block" "PublicAccess" {
    bucket = aws_s3_bucket.S3Bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

#Bucket Policy
resource "aws_s3_bucket_policy" "BucketPolicy" {
    bucket = aws_s3_bucket.S3Bucket.id
    policy = jsonencode(
        {
            Version = "2012-10-17"
            Statement = [
                {
                    Sid = "CloudFrontReadGetObject"
                    Effect = "Allow"
                    Principal = {
                        Service = "cloudfront.amazonaws.com"
                    }
                    Action = [
                        "s3:GetObject"
                    ]
                    Resource = "${aws_s3_bucket.S3Bucket.arn}/*"
                    Condition = {
                        StringEquals = {
                            "aws:SourceArn" = aws_cloudfront_distribution.MyCloudFront.arn
                        }
                    }

                }
            ]
        }
    )
}

#===============================================================================================================
#   CLOUDFRONT CONFIGURATION
#===============================================================================================================

#Locals
locals {
  s3_origin_id = "my-s3-origin"
}

#CloudFront Distribution
resource "aws_cloudfront_distribution" "MyCloudFront" {
    origin {
        domain_name = aws_s3_bucket.S3Bucket.bucket_regional_domain_name
        origin_id = local.s3_origin_id
        origin_access_control_id = aws_cloudfront_origin_access_control.MyOAC.id
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "CloudFront configuration for Next.js project"
    default_root_object = "index.html"

    default_cache_behavior {
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id
        viewer_protocol_policy = "https-only"
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
        locations = []
      }
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    tags = {
        Name = "CloudFront"
        Environment = "production"
    }
}

#OAC configuration
resource "aws_cloudfront_origin_access_control" "MyOAC"{
    name = "project-oac"
    description = "OAC configuration for S3"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}