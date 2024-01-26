variable "project_name" {
  description = "The name of the project"
  type = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type = string
}

variable "cluster_ca_certificate" {
  description = "CA Certificate for EKS cluster"
  type = string
}

variable "cluster_token" {
  description = "Token EKS cluster"
  type = string
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
  description = "port used by database"
  type    = number
}

variable "database_host" {
  default = "Database host's address"
  type    = string
}

variable "database_name" {
  default = "Name of database"
  type    = string
}


variable "lb_service_name" {
  type = string
  description = "Name of the Load Balancer K8s service that exposes the app"
}

variable "lb_service_port" {
  type = number
  description = "Port exposed of the Load Balancer K8s service assocaited to the app"
}
