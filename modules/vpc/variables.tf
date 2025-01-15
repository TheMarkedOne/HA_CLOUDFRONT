variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for public subnets within the VPC."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for private subnets within the VPC."
  type        = list(string)
}

variable "region" {
  description = "The AWS region where the resources will be deployed."
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones to deploy resources across."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "A flag to enable or disable the creation of NAT Gateways."
  type        = bool
}

variable "enable_igw" {
  description = "A flag to enable or disable the creation of an Internet Gateway."
  type        = bool
}
