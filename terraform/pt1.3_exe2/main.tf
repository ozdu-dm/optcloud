provider "aws" {
    region = "us-east-1"  
}

# Crear la VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "VPC_1.3_exe2"
    }
}

# Subnets
resource "aws_subnet" "subnet_a" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.32.0/25"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Subnet_1"
    }
}

resource "aws_subnet" "subnet_b" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.30.0/23"
    availability_zone = "us-east-1b"
    tags = {
        Name = "Subnet_2"
    }
}

resource "aws_subnet" "subnet_c" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.33.0/28"
    availability_zone = "us-east-1c"
    tags = {
        Name = "Subnet_C"
    }
}


# EC2 Instance

# SUBNET A
resource "aws_instance" "subnet_a_vm1" {
  ami = "ami-0341d95f75f311023"  # Amazon Linux
  instance_type = "t3.micro"
  subnet_id = aws_subnet.subnet_a.id

  tags = {
    Name = "Subnet_A_VM1"
  }
}

resource "aws_instance" "subnet_a_vm2" {
    ami = "ami-0341d95f75f311023"  # Amazon Linux
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_a.id
    
    tags = {
        Name = "Subnet_A_VM2"
    }
}

# SUBNET B
resource "aws_instance" "subnet_b_vm1" {
    ami = "ami-0341d95f75f311023"  # Amazon Linux
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_b.id
    tags = {
        Name = "Subnet_B_VM1"
    }
}

resource "aws_instance" "subnet_b_vm2" {
    ami = "ami-0341d95f75f311023"  # Amazon Linux
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_b.id
    
    tags = {
        Name = "Subnet_B_VM2"
    } 
}



# SUBNET C
resource "aws_instance" "subnet_c_vm1" {
    ami = "ami-0341d95f75f311023"  # Amazon Linux
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_c.id
    
    tags = {
        Name = "Subnet_C_VM1"
    }
}

resource "aws_instance" "subnet_c_vm2" {
    ami = "ami-0341d95f75f311023"  # Amazon Linux
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnet_c.id
    
    tags = {
        Name = "Subnet_C_VM2"
    }   
}
