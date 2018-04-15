resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name        = "${var.environment}-elasticache-subnet-group"
  description = "Elasticache subnet group"
  subnet_ids  = ["${var.subnet_ids}"]
  /*
    Does not support tags {}, see
    https://www.terraform.io/docs/providers/aws/r/elasticache_subnet_group.html
  */
}

resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id          = "${var.cluster_id}"
  replication_group_description = "Redis cluster for Hashicorp ElastiCache example"

  node_type            = "${var.instance_class}"
  port                 = 6379
  parameter_group_name = "default.redis3.2.cluster.on"

  snapshot_retention_limit = 5
  snapshot_window          = "00:00-05:00"

  security_group_ids = ["${aws_security_group.elasticache_sg.id}"]
  subnet_group_name = "${aws_elasticache_subnet_group.elasticache_subnet_group.name}"

  automatic_failover_enabled = true

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = "${var.node_groups}"
  }
}

resource "aws_security_group" "elasticache_access_sg" {
  name        = "${var.environment}-elasticache-access-sg"
  description = "Allow access to Elasticache"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name        = "${var.environment}-elasticache-access-sg"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "elasticache_sg" {
  name = "${var.environment}-elasticache-sg"
  description = "${var.environment} Security Group"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.environment}-rds-sg"
    Environment =  "${var.environment}"
  }

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  //allow traffic for TCP 6379
  ingress {
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    security_groups = ["${aws_security_group.elasticache_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
