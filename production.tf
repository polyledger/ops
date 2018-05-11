/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["us-east-1a", "us-east-1b"]
}

provider "aws" {
  region  = "${var.region}"
  // TODO: find a better system to manage these?
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "key" {
  key_name   = "production_key"
  public_key = "${file("production_key.pub")}"
}

module "networking" {
  source               = "./modules/networking"
  environment          = "production"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${local.production_availability_zones}"
  key_name             = "production_key"
}

module "ecs" {
  source              = "./modules/ecs"
  environment         = "production"
  vpc_id              = "${module.networking.vpc_id}"
  availability_zones  = "${local.production_availability_zones}"
  subnets_ids         = ["${module.networking.private_subnets_id}"]
  public_subnet_ids   = ["${module.networking.public_subnets_id}"]
  security_groups_ids = [
    "${module.networking.security_groups_ids}"
  ]
  secret_key_base          = "${var.production_secret_key_base}"
  email_host_password      = "${var.production_email_host_password}"
  npm_token                = "${var.production_npm_token}"
  bitbutter_api_key        = "${var.production_bitbutter_api_key}"
  bitbutter_api_secret     = "${var.production_bitbutter_api_secret}"
  bitbutter_partnership_id = "${var.production_bitbutter_partnership_id}"
  bitbutter_partner_id     = "${var.production_bitbutter_partner_id}"

  # Repositories config
  frontend_repository_name = "polyledger/production/frontend"
  server_repository_name = "polyledger/production/server"
}

module "code_pipeline" {
  npm_token                   = "${var.production_npm_token}"
  source                      = "./modules/code_pipeline"
  frontend_repository_url     = "${module.ecs.frontend_repository_url}"
  server_repository_url       = "${module.ecs.server_repository_url}"
  region                      = "${var.region}"
  ecs_service_name            = "${module.ecs.service_name}"
  ecs_cluster_name            = "${module.ecs.cluster_name}"
  run_task_subnet_id          = "${module.networking.private_subnets_id[0]}"
  run_task_security_group_ids = ["${module.networking.security_groups_ids}", "${module.ecs.security_group_id}"]
}
