provider "aws" {
  region  = var.aws_region
}

#----------------------------------------------------------------------------
# Data
#----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
# Get VPC by CIDR block
data "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

# Get Data Tier Subnets by CIDR block
data "aws_subnet" "public_az1" {
  cidr_block = var.public_az1_cidr_block
}

data "aws_subnet" "public_az2" {
  cidr_block = var.public_az2_cidr_block
}

data "aws_subnet" "public_az3" {
  cidr_block = var.public_az3_cidr_block
}

#----------------------------------------------------------------------------
# Security Group
#----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "frontend_sg" {
  name        = "Frontend Security Group"
  description = "Allow inbound logic tier traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "Frontend Security Group"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# ingress for CIDR range
resource "aws_security_group_rule" "frontend_sg_ingress_cidr" {
  for_each = {
    for frontend_sg_ingress_cidr_rule in var.frontend_sg_ingress_cidr_rules: 
      "${frontend_sg_ingress_cidr_rule.description}-${frontend_sg_ingress_cidr_rule.protocol}" => frontend_sg_ingress_cidr_rule
  }

  type              = "ingress"
  security_group_id = aws_security_group.frontend_sg.id

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidrs
}

# ingress for security group
resource "aws_security_group_rule" "frontend_sg_ingress_sg" {
  for_each = {
    for frontend_sg_ingress_sg_rule in var.frontend_sg_ingress_sg_rules: 
      "${frontend_sg_ingress_sg_rule.description}-${frontend_sg_ingress_sg_rule.protocol}" => frontend_sg_ingress_sg_rule
  }

  type                      = "ingress"
  security_group_id         = aws_security_group.frontend_sg.id

  from_port                 = each.value.from_port
  to_port                   = each.value.to_port
  protocol                  = each.value.protocol
  source_security_group_id  = each.value.sg_id
}

# egress for CIDR range
resource "aws_security_group_rule" "frontend_sg_egress_cidr" {
  for_each = {
    for frontend_sg_egress_cidr_rule in var.frontend_sg_egress_cidr_rules: 
      "${frontend_sg_egress_cidr_rule.description}-${frontend_sg_egress_cidr_rule.protocol}" => frontend_sg_egress_cidr_rule
  }

  type              = "egress"
  security_group_id = aws_security_group.frontend_sg.id

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidrs
}

# egress for security group
resource "aws_security_group_rule" "frontend_sg_egress_sg" {
  for_each = {
    for frontend_sg_egress_sg_rule in var.frontend_sg_egress_sg_rules: 
      "${frontend_sg_egress_sg_rule.description}-${frontend_sg_egress_sg_rule.protocol}" => frontend_sg_egress_sg_rule
  }

  type                      = "egress"
  security_group_id         = aws_security_group.frontend_sg.id

  from_port                 = each.value.from_port
  to_port                   = each.value.to_port
  protocol                  = each.value.protocol
  source_security_group_id  = each.value.sg_id
}

#----------------------------------------------------------------------------
# Autoscaling Group
#----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend"
  image_id      = "ami-042e8287309f5df03" # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  user_data = filebase64("${path.module}/frontend.sh")
  key_name = "frontend-key"
  # vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups = [aws_security_group.frontend_sg.id]
  }

  iam_instance_profile {
    name = "instance_profile_frontend"
  }
}

resource "aws_autoscaling_group" "frontend" {
  vpc_zone_identifier = [data.aws_subnet.public_az1.id, data.aws_subnet.public_az2.id, data.aws_subnet.public_az3.id]
  desired_capacity   = 0
  max_size           = 0
  min_size           = 0
  target_group_arns = [aws_lb_target_group.frontend_http.arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = aws_launch_template.frontend.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    # triggers = ["tag"]
  }
}

resource "aws_lb_target_group" "frontend_http" {
  name     = "frontend-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}

# resource "aws_autoscaling_attachment" "asg_attachment_frontend_http" {
#   autoscaling_group_name = aws_autoscaling_group.frontend.id
#   alb_target_group_arn   = aws_alb_target_group.frontend_http.arn
# }

# resource "aws_autoscaling_attachment" "asg_attachment_frontend_alb" {
#   autoscaling_group_name = aws_autoscaling_group.frontend.id
#   elb                    = aws_elb.bar.id
# }