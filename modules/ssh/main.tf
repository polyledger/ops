# We need to create an SSH host because the DB/Redis clusters are not accessible from
# the public internet, this will be attached to the same VPC so that we
# can test the clusters, this instance is fulfilling the role of the application server.

variable "environment" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}
variable "vpc_security_group_ids" { type = "list" }

resource "aws_security_group" "ssh_sg" {
  name        = "${var.environment}-ssh-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Bastion security group"

  tags {
    Name = "${var.environment}-ssh-sg"
    Environment = "${var.environment}"
  }

  lifecycle { create_before_destroy = true }

  ingress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    self = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the list of official Canonical Ubuntu 16.04 AMIs
data "aws_ami" "ubuntu-1604" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "startup" {
  template = "${file("${path.module}/startup.sh.tpl")}"
}

resource "aws_instance" "ssh_host" {
  ami           = "${data.aws_ami.ubuntu-1604.id}"
  instance_type = "t2.nano"
  key_name      = "${var.key_name}"

  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.ssh_sg.id}", "${var.vpc_security_group_ids}"]
  user_data              = "${data.template_file.startup.rendered}"

  tags {
    Name        = "${var.environment}-ssh-host"
    Environment = "${var.environment}"
  }
}

output "ssh_user" { value = "ubuntu" }
output "ssh_host" { value = "${aws_instance.ssh_host.public_ip}" }
