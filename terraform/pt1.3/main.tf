#configuracion de proveedor
provider "aws" {
  region = "us-east-1"
}

#crear instancia de EC2
resource "aws_instance" "instance1-exercici1" { 
  ami           = "ami-052064a798f08f0d3" #AMI de Amazon Linux 2 en us-east-1
  instance_type = "t3.micro"

  tags = {
    Name = "instancia-1"
  }
}

resource "aws_instance" "instance2-exercici1" { 
  ami           = "ami-052064a798f08f0d3" #AMI de Amazon Linux 2 en us-east-1
  instance_type = "t3.micro"

  tags = {
    Name = "instancia-2"
  }
}