# README

## Intro

This Terraform script is based on [this blog post](https://thecode.pub/easy-deploy-your-docker-applications-to-aws-using-ecs-and-fargate-a988a1cc842f), modified to work with a Django app (WIP).

## Infra overview

TODO

## Getting started

* `brew install terraform`
* `terraform init`
* `terraform apply -var 'access_key=foo' -var 'secret_key=bar'`

## TODO

- [ ] Update AWS region
- [ ] Enable code build/pipeline
- [ ] Rails -> Django
- [ ] Use Aurora Postgres
- [ ] Writer better README
- [ ] Add doc for different environments (different AWS accounts?)
