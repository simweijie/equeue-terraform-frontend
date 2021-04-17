#----------------------------------------------------------------------------
# Application Load Balancer
#----------------------------------------------------------------------------
resource "aws_lb" "frontend" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  subnets            = [data.aws_subnet.public_az1.id, data.aws_subnet.public_az2.id, data.aws_subnet.public_az3.id]

  enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "frontend-alb"
#     enabled = true
#   }

#   tags = {
#     Environment = "production"
#   }
}

resource "aws_lb_listener" "frontend_http_listener" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_http.arn
  }
}

#----------------------------------------------------------------------------
# Security Group
#----------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "frontend_alb_sg" {
  name        = "Frontend ALB Security Group"
  description = "Allow inbound logic tier traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "Frontend ALB Security Group"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
# ingress for CIDR range
resource "aws_security_group_rule" "frontend_alb_sg_ingress_cidr" {
  for_each = {
    for frontend_alb_sg_ingress_cidr_rule in var.frontend_alb_sg_ingress_cidr_rules: 
      "${frontend_alb_sg_ingress_cidr_rule.description}-${frontend_alb_sg_ingress_cidr_rule.protocol}" => frontend_alb_sg_ingress_cidr_rule
  }

  type              = "ingress"
  security_group_id = aws_security_group.frontend_alb_sg.id

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidrs
}

# ingress for security group
resource "aws_security_group_rule" "frontend_alb_sg_ingress_sg" {
  for_each = {
    for frontend_alb_sg_ingress_sg_rule in var.frontend_alb_sg_ingress_sg_rules: 
      "${frontend_alb_sg_ingress_sg_rule.description}-${frontend_alb_sg_ingress_sg_rule.protocol}" => frontend_alb_sg_ingress_sg_rule
  }

  type                      = "ingress"
  security_group_id         = aws_security_group.frontend_alb_sg.id

  from_port                 = each.value.from_port
  to_port                   = each.value.to_port
  protocol                  = each.value.protocol
  source_security_group_id  = each.value.sg_id
}

# egress for CIDR range
resource "aws_security_group_rule" "frontend_alb_sg_egress_cidr" {
  for_each = {
    for frontend_alb_sg_egress_cidr_rule in var.frontend_alb_sg_egress_cidr_rules: 
      "${frontend_alb_sg_egress_cidr_rule.description}-${frontend_alb_sg_egress_cidr_rule.protocol}" => frontend_alb_sg_egress_cidr_rule
  }

  type              = "egress"
  security_group_id = aws_security_group.frontend_alb_sg.id

  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidrs
}

# egress for security group
resource "aws_security_group_rule" "frontend_alb_sg_egress_sg" {
  for_each = {
    for frontend_alb_sg_egress_sg_rule in var.frontend_alb_sg_egress_sg_rules: 
      "${frontend_alb_sg_egress_sg_rule.description}-${frontend_alb_sg_egress_sg_rule.protocol}" => frontend_alb_sg_egress_sg_rule
  }

  type                      = "egress"
  security_group_id         = aws_security_group.frontend_alb_sg.id

  from_port                 = each.value.from_port
  to_port                   = each.value.to_port
  protocol                  = each.value.protocol
  source_security_group_id  = each.value.sg_id
}