# Defined when calling terraform apply -var 'access_key=foo' -var 'secret_key=bar'
variable "access_key" {}
variable "secret_key" {}

variable "region" {
  description = "Region that the instances will be created"
}

/*====
environment specific variables
======*/

variable "production_database_name" {
  description = "The database name for Production"
}

variable "production_database_username" {
  description = "The username for the Production database"
}

variable "production_database_password" {
  description = "The user password for the Production database"
}

variable "production_ec_cluster_id" {
  description = "The name of the Redis cluster"
}

variable "production_ec_node_groups" {
  description = "Number of Redis replicas"
}

variable "production_secret_key_base" {
  description = "The app secret key for production"
}

variable "domain" {
  default = "The domain of your application"
}
