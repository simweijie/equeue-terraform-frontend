variable "aws_region" {}

variable "vpc_cidr_block" {}
variable "public_az1_cidr_block" {}
variable "public_az2_cidr_block" {}
variable "public_az3_cidr_block" {}

variable "frontend_sg_ingress_cidr_rules" {}
variable "frontend_sg_ingress_sg_rules" {}
variable "frontend_sg_egress_cidr_rules" {}
variable "frontend_sg_egress_sg_rules" {}

variable "frontend_alb_sg_ingress_cidr_rules" {}
variable "frontend_alb_sg_ingress_sg_rules" {}
variable "frontend_alb_sg_egress_cidr_rules" {}
variable "frontend_alb_sg_egress_sg_rules" {}