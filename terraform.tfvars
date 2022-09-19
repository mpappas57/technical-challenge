#Networking Var Configs
environment = "tc-project"
vpc_cidr    = "10.1.0.0/16"
availability_zones = ["us-east-1a","us-east-1b"]
private_subnets_cidr = ["10.1.2.0/24","10.1.3.0/24"]
public_subnets_cidr = ["10.1.0.0/24","10.1.1.0/24"]

#EC2 Vars
name_server              = "tc-server"
ami                      =  "ami-06640050dc3f556bb"               
instance_type            =  "t2.micro"                               
associate_public_ip_address = true
key_name                 =  "tc-project"                 

#ASG Vars
name_asg = "tc-apache-asg"  
name_asg_ec2 = "tc-apache-ec2"


#S3 Bucket Var Configs
s3_bucket_name          = "tc-project2-s3"
s3_acl                  = "private"
block_public_acls       = true
block_public_policy     = true
ignore_public_acls      = true
restrict_public_buckets = true

