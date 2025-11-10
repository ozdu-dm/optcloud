variable "region" {
  default = "us-east-1"
}


variable "project_name" {
  default = "pt-1-5"
}


variable "instance_count" {
  default = 1
}


variable "subnet_count" {
  default = 2
}


variable "instance_type" {
  default = "t3.micro"
}


variable "instance_ami" {
  default = "ami-0157af9aea2eef346"
}


variable "create_s3_bucket" {
  default = true
}


variable "vpc_cidr" {
  default = "10.0.0.0/16"
}


variable "my_ip" {
  default = "0.0.0.0/0"
}
