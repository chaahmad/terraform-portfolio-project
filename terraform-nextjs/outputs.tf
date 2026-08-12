output "S3bucket" {
  description = "Name of newly created S3 bucket"
  value       = aws_s3_bucket.S3Bucket.id
}

output "CloudFront_URL" {
  description = "Link to CloudFront"
  value       = aws_cloudfront_distribution.MyCloudFront.domain_name
}