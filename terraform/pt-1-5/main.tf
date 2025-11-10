# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}


# Subnets
resource "aws_subnet" "public" {
  count                   = var.subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project_name}-public-${count.index}"
    Project = var.project_name
  }
}


resource "aws_subnet" "private" {
  count      = var.subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, var.subnet_count + count.index)
  tags = {
    Name    = "${var.project_name}-private-${count.index}"
    Project = var.project_name
  }
}


# Route Table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name    = "${var.project_name}-public-rt"
    Project = var.project_name
  }
}


resource "aws_route_table_association" "public_assoc" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Security Group
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}


# Instàncies públiques
resource "aws_instance" "public" {
  count                       = var.instance_count * var.subnet_count
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[count.index % length(aws_subnet.public)].id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  tags = {
    Name    = "${var.project_name}-public-${count.index}"
    Project = var.project_name
  }
}


# Instàncies privades
resource "aws_instance" "private" {
  count                       = var.instance_count * var.subnet_count
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private[count.index % length(aws_subnet.private)].id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = false
  tags = {
    Name    = "${var.project_name}-private-${count.index}"
    Project = var.project_name
  }
}


# Bucket S3 condicional
resource "aws_s3_bucket" "project" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = "${var.project_name}-buckett"
  tags = {
    Name    = "${var.project_name}-buckett"
    Project = var.project_name
  }
}
