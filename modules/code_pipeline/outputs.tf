output "frontend_assets_aws_s3_bucket_name" {
  value = "${aws_s3_bucket.client_assets.bucket_domain_name}"
}

output "frontend_assets_aws_s3_bucket_zone_id" {
  value = "${aws_s3_bucket.client_assets.hosted_zone_id}"
}
