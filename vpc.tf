# vpc.tf
# Create VPC/Subnet/Security Group/Network ACL

provider "aws" {
  region  = "us-east-2"
}

resource "aws_vpc" "My_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames
tags = {
    Name = "My VPC"
}
}
# create the Subnet
resource "aws_subnet" "My_VPC_Subnet_public1" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.public1subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone1
tags = {
   Name = "My VPC Public Subnet 1"
}
}
resource "aws_subnet" "My_VPC_Subnet_public2" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.public2subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP
  availability_zone       = var.availabilityZone2
tags = {
   Name = "My VPC Public Subnet 2"
}
}

resource "aws_subnet" "My_VPC_Subnet_private1" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.private1subnetCIDRblock
  map_public_ip_on_launch = var.mapNoPublicIP
  availability_zone       = var.availabilityZone1
tags = {
   Name = "My Private Subnet 1"
}
}

resource "aws_subnet" "My_VPC_Subnet_private2" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = var.private2subnetCIDRblock
  map_public_ip_on_launch = var.mapNoPublicIP
  availability_zone       = var.availabilityZone2
tags = {
   Name = "My Private Subnet 2"
}
}

# Create the Security Group
resource "aws_security_group" "My_VPC_Security_Group" {
  vpc_id       = aws_vpc.My_VPC.id
  name         = "My VPC Security Group"
  description  = "My VPC Security Group"

  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "My VPC Security Group"
   Description = "My VPC Security Group"
}
} # end resource

resource "aws_security_group" "My_LB_Security_Group" {
  vpc_id       = aws_vpc.My_VPC.id
  name         = "My VPC LB Security Group"
  description  = "My VPC LB Security Group"

  # allow ingress of port 80
  ingress {
    cidr_blocks = var.ingressCIDRblock
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "My VPC LB Security Group"
   Description = "My VPC LB Security Group"
}
} # end resource

# create VPC Network access control list
resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id = aws_vpc.My_VPC.id
#  subnet_ids = [ aws_subnet.My_VPC_Subnet.id ]
# allow ingress port 22
#  ingress {
#    protocol   = "tcp"
#    rule_no    = 100
#    action     = "allow"
#    cidr_block = var.destinationCIDRblock
#    from_port  = 22
#    to_port    = 22
#  }

  # allow ingress port 80
  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

#  # allow ingress ephemeral ports
#  ingress {
#    protocol   = "tcp"
#    rule_no    = 300
#    action     = "allow"
#    cidr_block = var.destinationCIDRblock
#    from_port  = 1024
#    to_port    = 65535
#  }

#  # allow egress port 22
#  egress {
#    protocol   = "tcp"
#    rule_no    = 100
#    action     = "allow"
#    cidr_block = var.destinationCIDRblock
#    from_port  = 22
#    to_port    = 22
#  }

  # allow egress port 80
#  egress {
#    protocol   = "tcp"
#    rule_no    = 200
#    action     = "allow"
#    cidr_block = var.destinationCIDRblock
#    from_port  = 80
#    to_port    = 80
#  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
tags = {
    Name = "My VPC ACL"
}
} # end resource

# Create the Internet Gateway
resource "aws_internet_gateway" "My_VPC_GW" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Internet Gateway"
}
} # end resource

# Create the Route Table
resource "aws_route_table" "My_VPC_Public_route_table" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Route Table"
}
} # end resource
resource "aws_route_table" "My_VPC_Private_route_table" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Private Route Table"
}
} # end resource

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id = "${aws_subnet.My_VPC_Subnet_public1.id}"

  tags = {
    Name = "NAT Gateway"
  }
}

# Create the Internet Access
resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_Public_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
} # end resource

resource "aws_route" "My_VPC_private_access" {
  route_table_id         = aws_route_table.My_VPC_Private_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_nat_gateway.gw.id
} # end resource

## Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Public1_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet_public1.id
  route_table_id = aws_route_table.My_VPC_Public_route_table.id
} # end resource

## Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Public2_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet_public2.id
  route_table_id = aws_route_table.My_VPC_Public_route_table.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Private1_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet_private1.id
  route_table_id = aws_route_table.My_VPC_Private_route_table.id
} # end resource

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "My_Private2_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet_private2.id
  route_table_id = aws_route_table.My_VPC_Private_route_table.id
} # end resource

data "aws_ami" "webserver" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20191116.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["137112412989"] # Canonical
}

resource "aws_elb" "web_elb" {
  name = "web-elb"
  security_groups = [
    "${aws_security_group.My_LB_Security_Group.id}"
  ]
  subnets = [
    "${aws_subnet.My_VPC_Subnet_public1.id}",
    "${aws_subnet.My_VPC_Subnet_public2.id}"
  ]
  cross_zone_load_balancing   = true
  depends_on = [ "aws_launch_configuration.web" ]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "TCP:80"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "80"
    instance_protocol = "http"
  }
}


## Creating Launch Configuration
#resource "aws_launch_configuration" "web" {
#  image_id               = "${data.aws_ami.webserver.id}"
#  instance_type          = "t2.micro"
#  security_groups        = ["${aws_security_group.My_VPC_Security_Group.id}"]
#  key_name               = "${var.key_name}"
#  associate_public_ip_address = false
#}

resource "aws_launch_configuration" "web" {
  name_prefix = "web-"
  image_id = "ami-0dacb0c129b49f529" # Amazon Linux AMI 2018.03.0 (HVM)
  instance_type = "t2.micro"
  key_name = "vinod"
  security_groups        = ["${aws_security_group.My_VPC_Security_Group.id}"]
  associate_public_ip_address = false
  depends_on = [ "aws_nat_gateway.gw" ]

  user_data = <<USER_DATA
#!/bin/bash
yum -y install httpd
curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone > /var/www/html/index.html
chkconfig httpd on
service httpd start
  USER_DATA

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4

  health_check_type    = "ELB"
  load_balancers= [
    "${aws_elb.web_elb.id}"
  ]

  launch_configuration = "${aws_launch_configuration.web.name}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity="1Minute"
  vpc_zone_identifier       = ["${aws_subnet.My_VPC_Subnet_private1.id}", "${aws_subnet.My_VPC_Subnet_private2.id}"]



  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}