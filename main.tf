module "networking" {
  source              = "./modules/networking"
  environment          = "${var.environment}"
  vpc_cidr             = "${var.vpc_cidr}"
  public_subnets_cidr  = "${var.public_subnets_cidr}"
  private_subnets_cidr = "${var.private_subnets_cidr}"
  availability_zones   = "${var.availability_zones}"
  
  name_server              = "${var.name_server}"
  ami                      =  "${var.ami}"              
  instance_type            =  "${var.instance_type}"                               
  associate_public_ip_address = "${var.associate_public_ip_address}"
  key_name                 =  "${var.key_name}"                 
  
  name_asg = "${var.name_asg}"
  name_asg_ec2 = "${var.name_asg_ec2}"
}

module "s3_bucket_project" {
    source                  = "./modules/s3"
    s3_bucket_name          = "${var.s3_bucket_name}"
    s3_acl                  = "${var.s3_acl}"
    block_public_acls       = "${var.block_public_acls}"
    block_public_policy     = "${var.block_public_policy}"
    ignore_public_acls      = "${var.block_public_acls}"
    restrict_public_buckets = "${var.restrict_public_buckets}"
}
