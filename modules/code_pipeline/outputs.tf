output "frontend_assets_aws_s3_bucket_name" {
  value = "${aws_s3_bucket.client_assets.website_domain}"
}

output "frontend_assets_aws_s3_bucket_zone_id" {
  value = "${aws_s3_bucket.client_assets.hosted_zone_id}"
}
