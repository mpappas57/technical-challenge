######  VPC #######
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
  }
}
#######  Subnets #######
#Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-igw"
  }
}
#Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}
#NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.ig]
  tags = {
    Name        = "nat"
  }
}
#Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr,   count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
  }
}
#Private subnet 
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones,   count.index)}"
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
  }
}
#Routing table for private subnet 
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-private-route-table"
  }
}
#Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name        = "${var.environment}-public-route-table"
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
# Route table associations 
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}
#VPC's Default Security Group 
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}
#######  EC2 #######
#Create security group for ssh traffic on tc_server
resource "aws_security_group" "sg" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tc-allow-ssh"
  }
}
#EC2 Key Pair Create
resource "tls_private_key" "ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2.public_key_openssh
}

#EC2 Web Create 
resource "aws_instance" "web" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   =  aws_subnet.public_subnet[1].id
  associate_public_ip_address = "${var.associate_public_ip_address}"
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id, aws_security_group.default.id]

  #root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.name_server}"
  }

}
#Assign elastic IP to EC2 Web
resource "aws_eip" "web" {
  vpc      = true
  instance = aws_instance.web.id
}

####### ASG & ALB For Apache Servers #######
#Create security group for http traffic on apache asg
resource "aws_security_group" "sg_apache" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    description      = "HTTP from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "apache-allow-http"
  }
}
#Create security group for ALB traffic on port 80
resource "aws_security_group" "sg_alb" {
  name = "apache-alb-sg"
  description = "Allow port 80 inbound traffic"
  vpc_id  = "${aws_vpc.vpc.id}"

  #Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "apache-alb-sg"
  }
}
#Create ALB 
resource "aws_lb" "alb_apache" {
  name               = "apache-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_alb.id]
  subnets            = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
}
#Create ALB target group 
resource "aws_lb_target_group" "tg_apache" {
  name     = "apache-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}
#Create ALB listeners 
resource "aws_lb_listener" "listner_apache" {
  load_balancer_arn = aws_lb.alb_apache.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_apache.arn
  }
}
#Create launch template for ASG 
resource "aws_launch_template" "apache_template" {
  name = "apache_template"
  
  image_id          = "${var.ami}"
  instance_type     = "${var.instance_type}"
  key_name          = "${var.key_name}"
  security_group_names   = ["aws_security_group.sg_apache.name", "aws_security_group.default.name"]
  
  monitoring {
    enabled = true
  }

}
#Create launch config for ASG
resource "aws_launch_configuration" "apache_launch_config" {
  image_id          = "${var.ami}"
  instance_type     = "${var.instance_type}"
  security_groups   = [aws_security_group.sg_apache.id, aws_security_group.default.id]
  key_name          = "${var.key_name}"
  user_data = <<-EOT
            #!/bin/bash
            echo "*** Installing apache2"
            sudo dnf install -y httpd
            echo "*** Completed Installing apache2"
  EOT
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_type = "gp2"
    volume_size = 20
    encrypted = true
  }
}
#Create ASG group for apache web servers
resource "aws_autoscaling_group" "apache_asg" {
  launch_configuration = aws_launch_configuration.apache_launch_config.id
  vpc_zone_identifier       = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
  name                      = "${var.name_asg}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  min_size = 2
  max_size = 6
  desired_capacity          = 2
  
  tag {
    key                 = "Name"
    value               = "${var.name_asg_ec2}"
    propagate_at_launch = true
  }
}
#Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.apache_asg.id
  lb_target_group_arn    = aws_lb_target_group.tg_apache.arn
}
