#######  Network Module Vars  #######
#VPC Vars
variable "environment" {}
variable "availability_zones" {}
variable "private_subnets_cidr" {}
variable "public_subnets_cidr" {}
variable "vpc_cidr" {}

#EC2 Vars
variable "name_server" {}
variable "ami" {}                         
variable "instance_type" {}              
variable "associate_public_ip_address" {} 
variable "key_name" {}  

#ASG Vars
variable "name_asg" {}
variable "name_asg_ec2" {}

#####  S3 Module Vars #####
variable "s3_bucket_name" {}
variable "s3_acl" {}               
variable "block_public_acls" {}     
variable "block_public_policy"     {}
variable "ignore_public_acls"     {}
variable "restrict_public_buckets" {}

