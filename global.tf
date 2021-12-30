# Global configuration
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Course = "Tech Foundations"
  }
}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Stream 8 x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["125523088429"]
}

resource "aws_subnet" "global" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Course = "Tech Foundations"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_internet_gateway" "global" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "global" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global.id
  }
}

resource "aws_route_table_association" "global" {
  subnet_id      = aws_subnet.global.id
  route_table_id = aws_route_table.global.id
}
