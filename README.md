# README

## Intro

This Terraform script is based on [this blog post](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f), modified to work with a Django app (WIP).

## Infra overview

TODO

## Settings

* Public SSH key/pair, edit `production_key.pub`
* The AWS region, main domain name, database credentials and the app secret are located
in `terraform.tfvars`.
* RDS instance size in `production.tf`
* Main container port and ENV variables in `modules/ecs/tasks/web_task_definition.json`
* Main container Github source in `modules/code_pipeline/main.tf`

## Getting started

* `brew install terraform`
* `terraform init`
* `terraform apply -var 'access_key=foo' -var 'secret_key=bar'`
* `terraform destroy -var 'access_key=foo' -var 'secret_key=bar'`

## TODO

- [ ] Enable code build/pipeline
- [ ] Rails -> Django
- [ ] Add ElastiCache Redis
- [ ] Use Aurora Postgres
- [ ] Writer better README
- [ ] DB backups
- [ ] Add doc for different environments (different AWS accounts?)
