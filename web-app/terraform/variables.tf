variable "instance_type" {
  description = "The type of EC2 instance to use"
  ami = "ami-0ec10929233384c7f"
  type = string
  default = "t3.micro"
}

locals {
 server_name = "web-server"
 owner = "3mr-devops"
 project = "ecommerce-microservices"
}

variable "db_password" {
  type      = string
  sensitive = true 
}

