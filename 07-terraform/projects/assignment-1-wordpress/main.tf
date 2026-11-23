terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "wordpress" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.wordpress.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "wordpress" {
  vpc_id = aws_vpc.wordpress.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wordpress.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "wordpress" {
  name        = "wordpress-http"
  description = "Allow public HTTP access to WordPress"
  vpc_id      = aws_vpc.wordpress.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.wordpress.id]
  user_data                   = file("${path.module}/user-data.sh")
  depends_on                  = [aws_route_table_association.public]

  tags = {
    Name = "terraform-wordpress"
  }
}

