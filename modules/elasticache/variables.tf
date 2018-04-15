variable "environment" {
  description = "The environment"
}

variable "instance_class" {
  description = "The instance type"
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet ids"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "node_groups" {
  description = "Number of replicas"
}

variable "cluster_id" {
  description = "Name of the cluster"
}
