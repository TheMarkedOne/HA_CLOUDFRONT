variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable "name_prefix" {
  description = "Name prefix for EC2 resources"
  type        = string
}

variable "elastic_ip" {
  description = "Elastic IP to share between active and passive instances"
  type        = string
}


variable "vpc_id" {
  
}
