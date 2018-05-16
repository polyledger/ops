# README

## Intro

This Terraform script is based on [this blog post](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f), modified to work with a Django app.

Another interesting resource: https://github.com/hashicorp/best-practices/tree/master/terraform/providers/aws.

## Infra overview

TODO

### Logs

ECS tasks logs will be sent to the us-east-1 region. This is specified in each task
definition JSON file. For more information see: [Using the awslogs Log Driver](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html).

## Settings

* Public SSH key/pair, edit `production_key.pub`
* The AWS region, main domain name, database credentials and the app secret are located
in `terraform.tfvars`.
* RDS/Elasticache instance size (and other vars) in `production.tf`
* Main container port and ENV variables in `modules/ecs/tasks/web.json`
* Main container Github source in `modules/code_pipeline/main.tf`
* CPU/RAM: need to be updated in `ecs/server.tf`/`ecs/task_definitions/server.json`, `ecs/frontend.tf`/`ecs/task_definitions/frontend.json`

## Getting started

* `brew install terraform`
* `terraform init`
* `terraform apply -var 'access_key=foo' -var 'secret_key=bar'`
* `terraform destroy -var 'access_key=foo' -var 'secret_key=bar'`

## Short term TODO

- [x] Enable code build/pipeline
- [x] Rails -> Django
- [x] Add ElastiCache Redis
- [x] Add public EC2 server that can connect to the DB and Redis
- [x] Update django sample app to connect from DATABASE_URL and REDIS_URL
- [x] Add Elastic IP for ssh (rename -> Bastion)
- [x] Setup domain name
- [ ] Setup Cloudfront
- [ ] Have the frontend use assets from Cloudfront
- [ ] Rename production to staging
- [x] Setup ALB
- [ ] SSL
- [x] Make sure admin works
- [ ] Add prod parity
- [ ] Writer better README

## Medium term TODO

- [ ] Replace supervisor by 3 distinct ECS tasks (celery, celery beat, server)
- [ ] Add health check for backend from ECS
- [ ] Add monitoring
- [ ] Settings for instance types/container sizes

## Long term TODO

- [ ] Add CI
- [ ] IAM users
- [ ] Use Aurora Postgres
- [ ] Add ECS service discovery (instead of Consul) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html
- [ ] DB backups? (should be included with Aurora)
- [ ] Add VPN to protect the EC2 instance
- [ ] Add Vault + Consul
- [ ] DB migrations? Maybe we need a console

## Questions

- Do we need nginx?
- ALB/ELB health check?
