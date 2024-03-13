
variable "region" {
  description = "aws region to deploy to"
  type        = string
}

variable "availability_zone" {
  type        = string
  description = "Availability zones for the RDS instance"
}

variable "vpc_id" {
  description = "VPC ID from which belogs the subnets"
  type        = string
}

variable "database_subnetids" {
  type        = list(string)
  description = "List of subnet IDs."
}

variable "database_username" {
  description = "Username for the master DB user."
  type        = string
}
variable "database_password" {
  description = "password of the database"
  type        = string
}

variable "database_port" {
  default = 5432
  type    = number
}

variable "database_name" {
  type    = string
  default = null
}