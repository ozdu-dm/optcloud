resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count      = var.private_instance_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index + 2)
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.private_instance_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH desde tu IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    description = "SSH hacia privadas"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

# Private SG
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "SSH desde bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "SSH entre privados"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "local_file" "bastion_private" {
  content  = tls_private_key.bastion_key.private_key_pem
  filename = "bastion.pem"
}

resource "tls_private_key" "private_key" {
  count     = var.private_instance_count
  algorithm = "RSA"
}

resource "aws_key_pair" "private_keypair" {
  count      = var.private_instance_count
  key_name   = "private-${count.index}"
  public_key = tls_private_key.private_key[count.index].public_key_openssh
}

resource "local_file" "private_key_file" {
  count    = var.private_instance_count
  content  = tls_private_key.private_key[count.index].private_key_pem
  filename = "private-${count.index + 1}.pem"
}

resource "aws_s3_bucket" "key_bucket" {
  bucket        = "keys-${random_id.bucket_id.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "key_bucket_ownership" {
  bucket = aws_s3_bucket.key_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "key_bucket_acl" {
  bucket = aws_s3_bucket.key_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.key_bucket_ownership]
}

resource "aws_s3_object" "bastion_pub" {
  bucket  = aws_s3_bucket.key_bucket.id
  key     = "bastion.pub"
  content = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_s3_object" "private_pub" {
  count   = var.private_instance_count
  bucket  = aws_s3_bucket.key_bucket.id
  key     = "private-${count.index}.pub"
  content = tls_private_key.private_key[count.index].public_key_openssh
}

resource "aws_instance" "bastion" {
  ami                    = "ami-0cae6d6fe6048ca2c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.bastion_keypair.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
}

resource "aws_instance" "private" {
  count                  = var.private_instance_count
  ami                    = "ami-0cae6d6fe6048ca2c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[count.index].id
  key_name               = aws_key_pair.private_keypair[count.index].key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
}

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/ssh_config.tpl", {
    bastion_ip = aws_instance.bastion.public_ip
    count      = var.private_instance_count
  })
  filename = "ssh_config_per_connectar.txt"
}