# Set Login details
# If you have AWS CLI and have run aws configure, then use the profile "default" and just set the region here
# Otherwise, remove "profile", uncomment the "access_key" / "secret_key" and fill in the details in the variables.tf file
provider "aws" {
  profile = "default"
  region  = "${var.region}"

  #  access_key = "${var.AWS_ACCESS_KEY_ID}"
  #  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_CIDR}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.vpc_name}"
  }
}

# VPC Endpoint for S3 service - required for Private Subnet to access S3 bucket
resource "aws_vpc_endpoint" "private_s3_endpoint" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_id       = "${aws_vpc.main.id}"
}

# Create Subnets
# Public first
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.public_CIDR}"
  availability_zone       = "${var.az}"
  map_public_ip_on_launch = true

  tags {
    Name = "Public Subnet"
  }
}

# Private next
resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.private_CIDR}"
  availability_zone       = "${var.az}"
  map_public_ip_on_launch = false

  tags {
    Name = "Private Subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Public Internet Gateway"
  }
}

# Create Route Table for Public Subnet that enables traffic through the Internet Gateway
# 0.0.0.0/0 is all internet traffic - pointing at the Internet Gateway created above
resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }

  tags {
    Name = "Public Route Table"
  }
}

# Associate Public Subnet with Public Route table
resource "aws_route_table_association" "assoc_public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

# Set Public Route table as the main Route table
# Required?
resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.public_route.id}"
}

# Create Route Table for Private Subnet, no default route set as we will associate all below
resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "Private Route Table"
  }
}

# Associate Private Subnet with Private Route table
resource "aws_route_table_association" "assoc_private" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}

# Associate VPC Endpoint for S3 with Private Route table
resource "aws_vpc_endpoint_route_table_association" "assoc_endpoint_private" {
  vpc_endpoint_id = "${aws_vpc_endpoint.private_s3_endpoint.id}"
  route_table_id  = "${aws_route_table.private_route.id}"
}

# Create Security Group for Private machine
resource "aws_security_group" "private_sg" {
  name        = "Internal Access"
  description = "Allow SSH Between Internal Machines"
  vpc_id      = "${aws_vpc.main.id}"
}

# Create SG Rule to attach to Security Group - Source being Public SG so only that machines with that SG can SSH in
resource "aws_security_group_rule" "allow_ssh_ingress_private" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.private_sg.id}"
  source_security_group_id = "${aws_security_group.public_sg.id}"
}

# Create SG Rule to attach to the Security Group - SSH to Public box 
resource "aws_security_group_rule" "allow_ssh_egress_private" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.private_sg.id}"
  source_security_group_id = "${aws_security_group.public_sg.id}"
}

# Create SG Rule to attach to the Security Group - VPC Endpoint for S3. Needed as no internet on this server
resource "aws_security_group_rule" "allow_http_egress_private" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.private_sg.id}"
  prefix_list_ids   = ["${aws_vpc_endpoint.private_s3_endpoint.prefix_list_id}"]
}

# Create SG Rule to attach to the Security Group - VPC Endpoint for S3. Needed as no internet on this server
resource "aws_security_group_rule" "allow_https_egress_private" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.private_sg.id}"
  prefix_list_ids   = ["${aws_vpc_endpoint.private_s3_endpoint.prefix_list_id}"]
}

# Create Security Group for Public Bastion
resource "aws_security_group" "public_sg" {
  name        = "Public Access"
  description = "Allow SSH, HTTP and HTTPS"
  vpc_id      = "${aws_vpc.main.id}"
}

# SG Rule to allow inbound SSH access from anywhere (needed for PuTTY access via internet)
resource "aws_security_group_rule" "allow_ssh_ingress_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# SG Rule for outbound SSH traffic. Linked to Private SG so can only connect to machines with Private SG
resource "aws_security_group_rule" "allow_ssh_egress_public" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.public_sg.id}"
  source_security_group_id = "${aws_security_group.private_sg.id}"
}

# SG Rule for outbound access to HTTP
resource "aws_security_group_rule" "allow_http_egress_public" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# SG Rule for outbound access to HTTPS
resource "aws_security_group_rule" "allow_https_egress_public" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.public_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Create Public EC2 Machine - Will act as Bastion Server - Link it to the Public Subnet
# Assign to the IAM role that can use the s3 bucket (just the one specified)
resource "aws_instance" "public_machine" {
  ami                    = "${data.aws_ami.latest_rhel.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.public.id}"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  user_data              = "${data.template_file.user_data_public.rendered}"

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags {
    Name = "Public EC2 Machine (Bastion)"
  }

  iam_instance_profile = "${aws_iam_instance_profile.s3_instance_profile.id}"
  depends_on           = ["aws_instance.private_machine"]
}

# Create Private EC2 Machine - Link it to the Private Subnet
# Remember, only accessible via the Public EC2 Machine (Bastion)
# Assign to the IAM role that can use the s3 bucket (just the one specified)
resource "aws_instance" "private_machine" {
  ami                    = "${data.aws_ami.latest_rhel.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.private.id}"
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  user_data              = "${data.template_file.user_data_private.rendered}"

  root_block_device {
    volume_size           = 10
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags {
    Name = "Private EC2 Machine"
  }

  iam_instance_profile = "${aws_iam_instance_profile.s3_instance_profile.id}"
}

# IAM role create for access between EC2 machines and S3 Bucket
resource "aws_iam_role" "s3_iam_role" {
  name = "s3_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]	
}
EOF
}

# Creates IAM Instance Profile
resource "aws_iam_instance_profile" "s3_instance_profile" {
  name = "s3_instance_profile"
  role = "s3_iam_role"
}

# Policy for IAM role above
resource "aws_iam_role_policy" "s3_iam_role_policy" {
  name = "s3_iam_role_policy"
  role = "${aws_iam_role.s3_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
        ],
      "Resource": ["arn:aws:s3:::public-private-s3-upload"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
        ],
      "Resource": ["arn:aws:s3:::public-private-s3-upload/*"]
    }
  ]
}
EOF
}

# S3 Bucket
resource "aws_s3_bucket" "apps_bucket" {
  bucket        = "public-private-s3-upload"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  tags {
    name = "public-private-s3-upload"
  }
}
