variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "AWS Cloud infrastructure region."
  type        = string
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the RDS instance"
}

variable "vpc_id" {
  description = "VPC ID from which belogs the subnets"
  type        = string
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "database_subnetids" {
  type        = list(string)
  description = "List of subnet IDs."
}

variable "replication_group_id" {
  description = "The name of the ElastiCache replication group."
  type        = string
}


variable "redis_port" {
  description = "ElastiCache port."
  type        = number
}