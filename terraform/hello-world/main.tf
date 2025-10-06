#configurar provedor
provider "aws" {
  region = "us-east-1"
}
#crear instancia de EC2
resource "aws_instance" "hello_world" { 
  ami           = "ami-052064a798f08f0d3" #AMI de Amazon Linux 2 en us-east-1
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-primer-vistazo"
  }
}