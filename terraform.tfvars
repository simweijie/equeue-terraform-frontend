#----------------------------------------------------------------------------
# AWS
#----------------------------------------------------------------------------
aws_region = "us-east-1"

#----------------------------------------------------------------------------
# General
#----------------------------------------------------------------------------
vpc_cidr_block          = "10.0.0.0/16"
public_az1_cidr_block   = "10.0.0.0/20"
public_az2_cidr_block   = "10.0.16.0/20"
public_az3_cidr_block   = "10.0.32.0/20"

#----------------------------------------------------------------------------
# Security Group
#----------------------------------------------------------------------------
frontend_alb_sg_ingress_cidr_rules = [
  { from_port: 80, to_port: 80, cidrs: ["0.0.0.0/0"], protocol: "tcp", description: "HTTP" },
  { from_port: 443, to_port: 443, cidrs: ["0.0.0.0/0"], protocol: "tcp", description: "HTTPS" }
]

frontend_alb_sg_ingress_sg_rules = [
]

frontend_alb_sg_egress_cidr_rules = [
  { from_port: 80, to_port: 80, cidrs: ["10.0.0.0/18"], protocol: "tcp", description: "HTTP" },     # to public tier target groups
  { from_port: 443, to_port: 443, cidrs: ["10.0.0.0/18"], protocol: "tcp", description: "HTTPS" }   # to public tier target groups
]

frontend_alb_sg_egress_sg_rules = [
]

frontend_sg_ingress_cidr_rules = [
  { from_port: 22, to_port: 22, cidrs: ["116.15.232.87/32"], protocol: "tcp", description: "SSH 1" },
  { from_port: 80, to_port: 80, cidrs: ["10.0.0.0/18"], protocol: "tcp", description: "HTTP" },     # from public tier ALB
  { from_port: 443, to_port: 443, cidrs: ["10.0.0.0/18"], protocol: "tcp", description: "HTTPS" }   # from public tier ALB
]

frontend_sg_ingress_sg_rules = [
#   { from_port: 3306, to_port: 3306, sg_id: "sg-123456", protocol: "tcp", description: "Bastion Host SG" }
]

frontend_sg_egress_cidr_rules = [
  { from_port: 80, to_port: 80, cidrs: ["0.0.0.0/0"], protocol: "tcp", description: "HTTP" },
  { from_port: 443, to_port: 443, cidrs: ["0.0.0.0/0"], protocol: "tcp", description: "HTTPS" }
]

frontend_sg_egress_sg_rules = [
]
