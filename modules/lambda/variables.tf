variable "active_instance_id" {
  description = "The ID of the active EC2 instance for the failover setup."
  type        = string
}

variable "passive_instance_id" {
  description = "The ID of the passive EC2 instance for the failover setup."
  type        = string
}

variable "eip" {
  description = "The Elastic IP address associated with the active EC2 instance."
  type        = string
}

variable "region" {
  description = "The AWS region where the resources will be deployed."
  type        = string
}