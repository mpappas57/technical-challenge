# Technical Challenege Documentation 

Perquisites to run this terraform repository in AWS environment:

1.	Create AWS account 
    a.	Direct to https://.aws.amazon.com/console/ and create an account 
2.	Create Administrator user and generate AWS CLI access keys for the user 
    a.	Direct yourself to IAM service in your AWS account and create a User giving them administrator access to the AWS console
3.	S3 bucket backend create 
    a.	On the AWS console S3 bucket on the AWS Console for terraform to use as a backend 
    b.	Find the backend.tf file and change the variable bucket and key values to the name of the bucket and the name of the folder you created. 
4.	Verify git is installed on your local 
    a.	Instructions link - https://www.linode.com/docs/guides/how-to-install-git-on-linux-mac-and-windows/ 
5.	Verify terraform is installed on your local 
    a.	Instructions link – https://learn.hashicorp.com/tutorials/terraform/install-cli 
6.	Verify AWS CLI is installed on your local 
    a.	Instructions link - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
7.	Run aws configure and enter you aws cli credentials from the administrator user you created
8.	Pull github repo to your local 
9.	Run command: terraform init 
10.	Run command: terraform plan
11.	Run command: terraform apply 

Configuration of terraform repo:

-	Two modules in the repo: networking and s3
-	Networking module creates:
    o	VPC
    o	Subnets (2 public and 2 private) 
    o	Routing tables (public and private) 
    o	Internet Gateway
    o	NAT w/ public IP
    o	Security groups
    o	EC2
    o	Application load balancer
    o	Auto scaling group
    o	Launch template 
-	S3 module creates
    o	S3 bucket with folders
    o	AWS KMS key
    o	Lifecycle policy(s)
-	Main.tf calls both of these modules with the necessary variables defined 
-	The values of the variables are stored in terraform.tfvars 
-	To change any values of the variables go to the terraform.tfvars to edit the variables value 
-	On the backend.tf file be sure to change the variable bucket and key values to the name of the bucket and the name of the folder you created.


