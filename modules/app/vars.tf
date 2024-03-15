variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "database_username" {
  description = "Username for the postgres DB user."
  type        = string
}

variable "database_password" {
  description = "password of the postgres database"
  type        = string
}

variable "database_port" {
  description = "port used by postgres database"
  type        = number
}

variable "database_host" {
  default = "Postgres database host's address"
  type    = string
}

variable "database_name" {
  default = "Name of postgres database"
  type    = string
}

variable "redis_port" {
  description = "port used by Redis database"
  type        = number
}

variable "redis_host" {
  default = "Redis database host's address"
  type    = string
}

variable "image_registry" {
  description = "The registry where the image is stored"
  type        = string
  default = "ghcr.io/soat1stackgolang"
}

variable "msvc_orders_image_tag" {
  description = "The tag of the image for the orders microservice"
  type        = string
  default = "msvc-develop"
}

variable "msvc_orders_migs_image_tag" {
  description = "The tag of the image for the orders microservice"
  type        = string
  default = "migs-develop"
}

variable "msvc_payments_image_tag" {
  description = "The tag of the image for the payments microservice"
  type        = string
  default = "msvc-develop"
}

variable "msvc_production_image_tag" {
  description = "The tag of the image for the products microservice"
  type        = string
  default = "msvc-develop"
}
