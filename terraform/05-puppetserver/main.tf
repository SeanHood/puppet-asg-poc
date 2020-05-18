
terraform {
  required_version = "~>0.12"
}

provider "aws" {
  region = "eu-west-2"
}


module "puppetserver" {
  source = "../modules/node_group"

  name          = "puppetserver"
  instance_type = "t3.micro"

  instance_security_group_ids = [aws_security_group.puppetserver.id]

  puppet_application = "idk"
  puppet_role        = "puppetserver"
}

resource "aws_security_group" "puppetserver" {
  name = "puppetserver-sg"

  ingress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# TODO: IAM Policy which allows the EC2 instance to fetch /puppet-asg-poc/deploy-key
