#Creating vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
}
#Public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_CIDR_1
  map_public_ip_on_launch = true # This condition makes the subnet as public, assigns ipv4 address
  availability_zone       = "us-east-2a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_CIDR_2
  map_public_ip_on_launch = true # This condition makes the subnet as public, assigns ipv4 address
  availability_zone       = "us-east-2b"
}


#Private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_CIDR_1
  availability_zone = "us-east-2a"

  # As the map_public_ip_on_launch is not provided, it is by default false which makes it private subnet
}

#Private subnet
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_CIDR_2
  availability_zone = "us-east-2b"

  # As the map_public_ip_on_launch is not provided, it is by default false which makes it private subnet
}
#public subnet Route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
}

#Route table mapping to public subnet and route table
resource "aws_route_table_association" "public_subnet_one_route_map" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_route_table.public_route_table]
}

resource "aws_route_table_association" "public_subnet_two_route_map" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
  depends_on     = [aws_route_table.public_route_table]
}

#Internet gateway for access to the internet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_acess_to_internetgateway_one" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

#Private subnet route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
}

#Route table mapping to private subnet and route table
resource "aws_route_table_association" "private_subnet_one_route_map" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on     = [aws_route_table.private_route_table]
}

resource "aws_route_table_association" "private_subnet_two_route_map" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
  depends_on     = [aws_route_table.private_route_table]
}


resource "aws_launch_template" "launch_template" {
  name_prefix   = "dev-servers"
  image_id      = "ami-085f9c64a9b75eed5"
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "autoscaling" {
  name                      = "dev-autoscaling"
  min_size                  = 1
  max_size                  = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

}

resource "aws_security_group" "dev-security_group" {
  name   = "dev-sec-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "dev-loadbalancer" {
  name               = "dev-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dev-security_group.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = true

  tags = {
    Environment = "dev"
  }
}

