
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


variable "lb_service_name_orders" {
  type = string
  description = "Name of the Load Balancer K8s service that exposes the orders microservices"
}


variable "lb_service_port_orders" {
  type = number
  description = "Port exposed of the Load Balancer K8s service associated to the orders microservices"
}


variable "lb_service_name_production" {
  type = string
  description = "Name of the Load Balancer K8s service that exposes the production microservices"
}


variable "lb_service_port_production" {
  type = number
  description = "Port exposed of the Load Balancer K8s service associated to the production microservices"
}

variable "cognito_user_name" {
  type    = string
  default = "11122233300"
}


variable "cognito_user_password" {
  type    = string
  default = "F@ap1234"
}