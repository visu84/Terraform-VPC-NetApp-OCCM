variable "aws_access_key" {}
variable "aws_secret_key" {}


variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
}

variable "vpc_name" {
	description	= "Name tag for VPC"
}

variable "az_1" {
	description ="Avaiability Zone 1"
}
variable "az_2" {
	description	="Avaiability Zone 2"
}

variable "public_subnet1_cidr" {
    description = "CIDR for the Public Subnet"
}

variable "public_subnet1_name" {
	description = "Name tag for the public_subnet1"
}

variable "public_subnet2_cidr" {
    description = "CIDR for the Public Subnet"
}

variable "public_subnet2_name" {
	description = "Name tag for the public_subnet2"
}

variable "private_subnet1_cidr" {
    description = "CIDR for the Private Subnet"
}

variable "private_subnet1_name" {
	description = "Name tag for the private_subnet1"
}

variable "private_subnet2_cidr" {
    description = "CIDR for the Private Subnet"
}
variable "private_subnet2_name" {
	description = "Name tag for the private_subnet2"
}

variable "igw_name" {
	description = "Name tag for IGW"
}

variable "nat_name" {
	description = "Name tag for NAT Gateway"
}

variable "public_RT" {
	description = "Name tag for Public RT"
}

variable "private_RT" {
	description = "Name tag for Private RT"
}
variable "occm_name" {
	description ="Name tag for OnCommand cloud manager instance"
}

/*
OnCommand Cloud Manager specific
*/
variable "occm_email" {
  description = "Email address (username) for OnCommand Cloud Manager instance"
}

variable "occm_password" {
  description = "Administrative password for OnCommand Cloud Manager instance"
}

variable "company_name" {
  description = "Your company name to which the OnCommand Cloud manager system will be registered"
}

variable "occm_amis" {
  type = "map"
  description = "List of the OnCommand Cloud Manager AMIs per region."
  default = {
    "us-east-1"      = "ami-14493c6b"
  }
}
variable "key_name" {
  description = "Existing AWS KeyPair name"
}
