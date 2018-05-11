variable "environment" {
  description = "The environment"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "availability_zones" {
  type        = "list"
  description = "The azs to use"
}

variable "security_groups_ids" {
  type        = "list"
  description = "The SGs to use"
}

variable "subnets_ids" {
  type        = "list"
  description = "The private subnets to use"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The private subnets to use"
}

variable "frontend_repository_name" {
  description = "The name of the ECR repository for the web client"
}

variable "server_repository_name" {
  description = "The name of the ECR repository for the server"
}

variable "secret_key_base" {
  description = "The secret key base to use in the app"
}

variable "email_host_password" {}
variable "npm_token" {}
variable "bitbutter_api_key" {}
variable "bitbutter_api_secret" {}
variable "bitbutter_partnership_id" {}
variable "bitbutter_partner_id" {}
