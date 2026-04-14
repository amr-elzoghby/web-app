locals {
  server_name = "web-server"
  owner       = "3mr-devops"
  project     = "ecommerce-microservices"

  # Common name prefix used across all resources
  name_prefix = "${local.project}-${var.environment}"

  # Subnets CIDR map
  subnets = {
    public_1  = "10.0.1.0/24"
    public_2  = "10.0.2.0/24"
    private_1 = "10.0.3.0/24"
    private_2 = "10.0.4.0/24"
  }
}
