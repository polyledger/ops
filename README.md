# README

## Intro

This Terraform script is based on [this blog post](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f), modified to work with a Django app (WIP).

## Infra overview

TODO

## Settings

* Public SSH key/pair, edit `production_key.pub`
* The AWS region, main domain name, database credentials and the app secret are located
in `terraform.tfvars`.
* RDS/Elasticache instance size (and other vars) in `production.tf`
* Main container port and ENV variables in `modules/ecs/tasks/web_task_definition.json`
* Main container Github source in `modules/code_pipeline/main.tf`
* CPU/RAM: TODO

## Getting started

* `brew install terraform`
* `terraform init`
* `terraform apply -var 'access_key=foo' -var 'secret_key=bar'`
* `terraform destroy -var 'access_key=foo' -var 'secret_key=bar'`

## TODO

- [x] Enable code build/pipeline
- [x] Rails -> Django
- [x] Add ElastiCache Redis
- [x] Add public EC2 server that can connect to the DB and Redis
- [x] Update django sample app to connect from DATABASE_URL and REDIS_URL
- [ ] Add public IP for ssh (rename -> Bastion)
- [x] Setup domain name
- [ ] IAM users
- [ ] Use Aurora Postgres
- [ ] Add VPN to protect the EC2 instance
- [ ] Add CI
- [ ] DB migrations? Maybe we need a console
- [ ] Add staging (+ prod) parity
- [ ] Writer better README
- [ ] DB backups?
