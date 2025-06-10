variable "VPC_CIDR" {

}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "common_tags" {
  type = map
}

variable "Project_name" {
  
}


variable "environment" {
  
}

variable "vpc_tags" {
  default = {}
}

variable "igw_tags" {
  default = {}
}

variable "public_subnet_tags" {
  default = {}
}

variable "private_subnet_tags" {
  default = {}
}

variable "database_subnet_tags" {
  default = {}
}

variable "public_route_tags" {
  default = {}
}

variable "private_route_tags" {
  default = {}
}

variable "database_route_tags" {
  default = {}
}

variable "public_subnet_cidr" {
  type = list
  validation {
    condition = length(var.public_subnet_cidr) == 2
    error_message = "Please provide atleast 2 public subnet cidr's"
  }
}

variable "private_subnet_cidr" {
  type = list
  validation {
    condition = length(var.private_subnet_cidr) == 2
    error_message = "Please provide atleast 2 private subnet cidr's"
  }
}

variable "database_subnet_cidr" {
  type = list
  validation {
    condition = length(var.database_subnet_cidr) == 2
    error_message = "Please provide atleast 2 database subnet cidr's"
  }
}