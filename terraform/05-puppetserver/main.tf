
terraform {
  required_version = "~>0.12"
}

provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {}

module "puppetserver" {
  source = "../modules/node_group"

  name          = "puppetserver"
  instance_type = "t3.micro"

  instance_security_group_ids = [aws_security_group.puppetserver.id]

  instance_key_name = var.demo-instance_key_name
  instance_public_key = var.demo-instance_public_key

  puppet_application = "idk"
  puppet_role        = "puppetserver"
}

resource "aws_security_group" "puppetserver" {
  name = "puppetserver-sg"

  ingress {
    description = "SSH"
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = [var.demo-my-ip]
  }

  ingress {
    description = "Allow Puppet to everything in our VPC"
    from_port = 8140
    protocol = "TCP"
    to_port = 8140
    cidr_blocks = ["172.31.0.0/16"] # TODO: Replace with security group rather than CIDR's
  }

  egress {
    description = "Allow everything to go out"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_policy" "node_iam_policy_puppet_deploykey" {
  name   = "puppetserver-puppet-deploy-key"
  path   = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1589877506030",
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/puppet-asg-poc/ssh-key"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_iam_role_policy_attachment_default" {
  role       = module.puppetserver.instance_iam_role_name
  policy_arn = aws_iam_policy.node_iam_policy_puppet_deploykey.arn
}

