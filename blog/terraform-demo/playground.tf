provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "risx-terraform-state"
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
}

data "terraform_remote_state" "playground" {
  backend = "s3"
  config {
    bucket = "risx-terraform-state"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

variable "ami" { "default" = "ami-db710fa3" }
variable "env" { "default" = "dev" }

resource "aws_security_group" "playground" {
  name        = "playground SG"
  description = "ports wanted/needed for the playground instance"
  vpc_id      = "vpc-b9db38dc"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # maybe later if i ever had a VPN it'd be worth limiting this
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "playground"
    Environment = "${var.env}"
    Created     = "${timestamp()}" 
  }
}

resource "aws_instance" "playground" {
    ami             = "${var.ami}"
    instance_type   = "t2.nano"
    count           = 1
    key_name        = "automation"

    vpc_security_group_ids = ["${aws_security_group.playground.id}"]

    tags = {
        Name        = "playground"
        Environment = "${var.env}"
        Created     = "${timestamp()}" 
    }

}