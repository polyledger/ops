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

variable "staging_database_name" {
  description = "The database name for staging"
}

variable "staging_database_username" {
  description = "The username for the staging database"
}

variable "staging_database_password" {
  description = "The user password for the staging database"
}

variable "staging_ec_node_groups" {
  description = "Number of Redis replicas"
}

variable "staging_secret_key_base" {
  description = "The app secret key for staging"
}

variable "domain" {
  default = "The domain of your application"
}

variable "staging_email_host_password" {}
variable "staging_npm_token" {}
variable "staging_bitbutter_api_key" {}
variable "staging_bitbutter_api_secret" {}
variable "staging_bitbutter_partnership_id" {}
variable "staging_bitbutter_partner_id" {}
