
terraform {
  required_version = "~>0.12"
}

provider "aws" {
  region = "eu-west-2"
}

// Boiler plate: Fetch the default VPC and Subnets
data "aws_vpc" "main" {
  default = true
}
data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.main.id
}

module "central" {
  source = "../modules/node_group"


  instance_security_group_ids = [aws_security_group.central-sg.id]
  instance_type               = "t3.micro"
  name                        = "central"
  puppet_application          = "blue"
  puppet_role                 = "central"

  asg_min_size         = 3
  asg_desired_capacity = 6
  asg_max_size         = 10

  instance_target_group_arns = [aws_alb_target_group.nodes.arn]
}

// SG for our nodes
resource "aws_security_group" "central-sg" {
  name = "central-sg"

  ingress {
    from_port = 22
    protocol = "TCP"
    to_port = 22
    cidr_blocks = [var.demo-my-ip]
  }

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    security_groups = [aws_security_group.lb_security_group.id] // Best Practice: Use security groups to refer to other security groups
  }

  // Security is totes optional in demos, yeah? Don't do this in prod if you can help it
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// We have a loadbalancer
resource "aws_alb" "central" {
  name    = "central"
  subnets = data.aws_subnet_ids.subnets.ids
  security_groups = [aws_security_group.lb_security_group.id]
}

// A loadbalancer needs to listen on a port
resource "aws_alb_listener" "central" {
  load_balancer_arn = aws_alb.central.arn
  port              = 80
  protocol          = "http"

  // We need a default rule, in this case send all traffic to the nodes target group
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nodes.arn
  }
}

// We need a Target Group for nodes to be apart of
resource "aws_alb_target_group" "nodes" {
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 80
  }
}

// Attach the nodes that come up in an ASG to the Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.central.autoscaling_group_name
  alb_target_group_arn   = aws_alb_target_group.nodes.arn
}


// Allow all traffic from the internet into our ALB
resource "aws_security_group" "lb_security_group" {
  name = "lb-sg"

  ingress {
    from_port = 80
    protocol = "TCP"
    to_port = 80
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}