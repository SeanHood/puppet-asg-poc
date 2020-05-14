variable "name" {
  type = string
}

variable "subnets" {
  type    = list(string)
  default = ["subnet-1b7d1a56", "subnet-1b7d1a56", "subnet-1b7d1a56"]
}

variable "root_block_device_volume_size" {
  type        = number
  default     = 20
  description = "The size of the instance root volume in gigabytes"
}

variable "instance_type" {
  type = string
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 1
}

variable "asg_health_check_grace_period" {
  type        = string
  description = "The time to wait after creation before checking the status of the instance"
  default     = "60"
}

variable "instance_key_name" {
  type    = string
  default = ""
}

variable "instance_public_key" {
  type    = string
  default = ""
}

variable "instance_target_group_arns" {
  type    = set(string)
  default = []
}

variable "instance_security_group_ids" {
  type = list(string)
}

variable "puppet_role" {
  type        = string
  description = "Puppet node role name"
}

variable "puppet_application" {
  type        = string
  description = "Puppet node application name"
}

variable "default_tags" {
  type        = map(string)
  description = "Additional resource tags"
  default     = {}
}

# Oh my god, what am I doing?
locals {
  puppet_userdata = var.puppet_role == "puppetserver" ? "20-puppetserver" : "20-puppet-client"
}


data "aws_ami" "latest-centos-7" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_key_pair" "node_key" {
  key_name   = var.instance_key_name
  public_key = var.instance_public_key
}

resource "aws_iam_role" "node_iam_role" {
  name = var.name
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "node_iam_policy_default" {
  name   = "${var.name}-default"
  path   = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1499440543000",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_iam_role_policy_attachment_default" {
  role       = aws_iam_role.node_iam_role.name
  policy_arn = aws_iam_policy.node_iam_policy_default.arn
}

resource "aws_iam_instance_profile" "node_instance_profile" {
  name = var.name
  role = aws_iam_role.node_iam_role.name
}

resource "aws_launch_configuration" "node_launch_configuration" {
  name_prefix = "${var.name}-"

  image_id      = data.aws_ami.latest-centos-7.image_id
  instance_type = var.instance_type


  user_data_base64 = base64encode(join("\n\n", [for i in ["00-base", local.puppet_userdata] : file("${path.module}/userdata/${i}")]))

  security_groups             = var.instance_security_group_ids
  iam_instance_profile        = aws_iam_instance_profile.node_instance_profile.name
  associate_public_ip_address = false

  key_name = var.instance_key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node_autoscaling_group" {
  name = var.name

  vpc_zone_identifier = var.subnets

  max_size         = var.asg_max_size
  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity

  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = aws_launch_configuration.node_launch_configuration.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  tag {
    key                 = "aws_role"
    value               = var.puppet_role
    propagate_at_launch = true
  }

  tag {
    key                 = "aws_application"
    value               = var.puppet_application
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.default_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_attachment" "node_autoscaliing_group_alb" {
  for_each               = var.instance_target_group_arns
  autoscaling_group_name = aws_autoscaling_group.node_autoscaling_group.id
  alb_target_group_arn   = each.key
}

