/*
 * Prompted for these values when calling `terraform apply`
 * You can also pass to the command like:
 * `terraform apply -var 'access_key=foo' -var 'secret_key=bar'`
 */
variable "access_key" {
  description = "Your AWS access key"
}

variable "secret_key" {
  description = "Your AWS secret key"
}

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

variable "production_ec_node_groups" {
  description = "Number of Redis replicas"
}

variable "production_secret_key_base" {
  description = "The app secret key for production"
}

variable "domain" {
  default = "The domain of your application"
}

variable "production_email_host_password" {}
variable "production_npm_token" {}
variable "production_bitbutter_api_key" {}
variable "production_bitbutter_api_secret" {}
variable "production_bitbutter_partnership_id" {}
variable "production_bitbutter_partner_id" {}
