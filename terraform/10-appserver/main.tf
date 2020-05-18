terraform {
  required_version = "~>0.12"
}

provider "aws" {
  region = "eu-west-2"
}


module "appserver" {
  source = "../modules/node_group"

  name          = "appserver"
  instance_type = "t3.micro"

  instance_security_group_ids = [aws_security_group.appserver.id]

  puppet_application = "blue"
  puppet_role        = "appserver"
}

resource "aws_security_group" "appserver" {
  name = "appserver-sg"

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["88.98.85.22/32"]
  }

  ingress {
    from_port   = 80
    protocol    = "TCP"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}