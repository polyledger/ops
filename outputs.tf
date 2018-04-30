output "alb_dns_name" {
  value = "${module.ecs.alb_dns_name}"
}

output "configuration" {
  value = <<CONFIGURATION
Add your private key and SSH into any private node via the Bastion host:
ssh-add ../../../modules/keys/demo.pem
ssh -A ${module.bastion.user}@${module.bastion.public_ip}
CONFIGURATION
}
