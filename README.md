# Technical Challenege Documentation 

Perquisites to run this terraform repository in AWS environment:

1.	Create AWS account 
     -	a.	Direct to https://portal.aws.amazon.com and create an account 
3.	Create Administrator user and generate AWS CLI access keys for the user 
     -	a.	Direct yourself to IAM service in your AWS account and create a User giving them administrator access to the AWS console
3.	S3 bucket backend create 
     -	a. On the AWS console S3 bucket on the AWS Console for terraform to use as a backend 
     -	b.	Find the backend.tf file and change the variable bucket and key values to the name of the bucket and the name of the folder you created. 
4.	Verify git is installed on your local 
     -	a.	Instructions link - https://www.linode.com/docs/guides/how-to-install-git-on-linux-mac-and-windows/ 
5.	Verify terraform is installed on your local 
     -	a.	Instructions link – https://learn.hashicorp.com/tutorials/terraform/install-cli 
6.	Verify AWS CLI is installed on your local 
     -	a.	Instructions link - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
7.	Run aws configure and enter you aws cli credentials from the administrator user you created
8.	Pull github repo to your local 
9.	Run command: terraform init 
10.	Run command: terraform plan
11.	Run command: terraform apply 

Configuration of terraform repo:

-	Two modules in the repo: networking and s3
-	Networking module creates:
     -	VPC
     -	Subnets (2 public and 2 private) 
     -	Routing tables (public and private) 
     -	Internet Gateway
     -	NAT w/ public IP
     -	Security groups
     -	EC2
     -	Application load balancer
     -	Auto scaling group
     -	Launch template 
-	S3 module creates:
     -	S3 bucket with folders
     -	AWS KMS key
     -	Lifecycle policy(s)
-	Main.tf calls both of these modules with the necessary variables defined 
-	The values of the variables are stored in terraform.tfvars 
-	To change any values of the variables go to the terraform.tfvars to edit the variables value 
-	On the backend.tf file be sure to change the variable bucket and key values to the name of the bucket and the name of the folder you created.

Architecture Diagram of Terraform Repo:
<img width="975" alt="Screen Shot 2022-09-18 at 10 17 55 PM" src="https://user-images.githubusercontent.com/56840177/190953745-7e7d46f3-4135-43c5-9431-91d986b866e5.png">

