#vpc & subnet
variable "environment" {}
variable "availability_zones" {}
variable "private_subnets_cidr" {}
variable "public_subnets_cidr" {}
variable "vpc_cidr" {}

#ec2
variable "name_server" {}
variable "ami" {}                         
variable "instance_type" {}              
variable "associate_public_ip_address" {} 
variable "key_name" {}                   

#ASG
variable "name_asg" {}
variable "name_asg_ec2" {}
