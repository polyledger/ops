/*====
Variables used across all modules
======*/
locals {
  staging_availability_zones = ["us-east-1a", "us-east-1b"]
}

provider "aws" {
  region  = "${var.region}"
  // TODO: find a better system to manage these?
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_key_pair" "key" {
  key_name   = "staging_key"
  public_key = "${file("staging_key.pub")}"
}

module "networking" {
  source               = "./modules/networking"
  environment          = "staging"
  vpc_cidr             = "10.0.0.0/16"
  public_subnets_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidr = ["10.0.10.0/24", "10.0.20.0/24"]
  region               = "${var.region}"
  availability_zones   = "${local.staging_availability_zones}"
}

module "rds" {
  source            = "./modules/rds"
  environment       = "staging"
  allocated_storage = "20"
  database_name     = "${var.staging_database_name}"
  database_username = "${var.staging_database_username}"
  database_password = "${var.staging_database_password}"
  subnet_ids        = ["${module.networking.private_subnets_id}"]
  vpc_id            = "${module.networking.vpc_id}"
  instance_class    = "db.t2.micro"
}

module "elasticache" {
  source            = "./modules/elasticache"
  environment       = "staging"
  # https://aws.amazon.com/elasticache/pricing/
  instance_class    = "cache.t2.micro"
  node_groups       = "${var.staging_ec_node_groups}"
  cluster_id        = "staging-redis"
  subnet_ids        = ["${module.networking.private_subnets_id}"]
  vpc_id            = "${module.networking.vpc_id}"
}

module "ecs" {
  source              = "./modules/ecs"
  environment         = "staging"
  vpc_id              = "${module.networking.vpc_id}"
  availability_zones  = "${local.staging_availability_zones}"
  subnets_ids         = ["${module.networking.private_subnets_id}"]
  public_subnet_ids   = ["${module.networking.public_subnets_id}"]
  security_groups_ids = [
    "${module.networking.security_groups_ids}",
    "${module.rds.db_access_sg_id}",
    "${module.elasticache.elasticache_access_sg_id}"
  ]
  database_endpoint        = "${module.rds.rds_address}"
  database_name            = "${var.staging_database_name}"
  database_username        = "${var.staging_database_username}"
  database_password        = "${var.staging_database_password}"
  redis_endpoint           = "${module.elasticache.elasticache_endpoint}"
  secret_key_base          = "${var.staging_secret_key_base}"
  email_host_password      = "${var.staging_email_host_password}"
  npm_token                = "${var.staging_npm_token}"
  bitbutter_api_key        = "${var.staging_bitbutter_api_key}"
  bitbutter_api_secret     = "${var.staging_bitbutter_api_secret}"
  bitbutter_partnership_id = "${var.staging_bitbutter_partnership_id}"
  bitbutter_partner_id     = "${var.staging_bitbutter_partner_id}"

  # Repositories config
  frontend_repository_name = "polyledger/staging/frontend"
  server_repository_name = "polyledger/staging/server"
}

module "bastion" {
  source      = "./modules/bastion"
  environment = "staging"
  vpc_id      = "${module.networking.vpc_id}"
  subnet_id   = "${module.networking.public_subnets_id[0]}"
  vpc_security_group_ids = [
    "${module.elasticache.elasticache_access_sg_id}",
    "${module.rds.db_access_sg_id}"
  ]
  key_name    = "${aws_key_pair.key.id}"
}

module "code_pipeline" {
  npm_token                   = "${var.staging_npm_token}"
  source                      = "./modules/code_pipeline"
  frontend_repository_url     = "${module.ecs.frontend_repository_url}"
  server_repository_url       = "${module.ecs.server_repository_url}"
  region                      = "${var.region}"
  ecs_service_name            = "${module.ecs.service_name}"
  ecs_cluster_name            = "${module.ecs.cluster_name}"
  run_task_subnet_id          = "${module.networking.private_subnets_id[0]}"
  run_task_security_group_ids = ["${module.networking.security_groups_ids}", "${module.ecs.security_group_id}"]
}

module "cloudfront" {
  source = "./modules/cloudfront"
  frontend_assets_aws_s3_bucket_name = "${module.code_pipeline.frontend_assets_aws_s3_bucket_name}"
}
