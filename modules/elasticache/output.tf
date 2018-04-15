output "elasticache_access_sg_id" {
  value = "${aws_security_group.elasticache_access_sg.id}"
}

output "elasticache_endpoint" {
  value = "${aws_elasticache_replication_group.elasticache.configuration_endpoint_address}"
}
