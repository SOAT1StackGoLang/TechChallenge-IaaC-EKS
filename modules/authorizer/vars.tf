
variable "project_name" {
  description = "The name of the project"
  type = string
}

variable vpc_id {
  description = "VPC ID from which belogs the subnets"
  type        = string
}

variable "region" {
  description = "aws region to deploy to"
  type        = string
}

variable "private_subnet_ids" {
  type = list(string)
  description = "List of subnet IDs."
}

variable "environment" {
  type    = string
  default = "dev"
}


variable "lb_service_name" {
  type = string
  description = "Name of the Load Balancer K8s service that exposes the app"
}


variable "lb_service_port" {
  type = number
  description = "Port exposed of the Load Balancer K8s service assocaited to the app"
}


variable "cognito_user_name" {
  type    = string
  default = "11122233300"
}


variable "cognito_user_password" {
  type    = string
  default = "F@ap1234"
}