variable "project_name" {
  description = "The name of the project"
  type = string
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
  type    = number
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
  type    = number
}

variable "redis_host" {
  default = "Redis database host's address"
  type    = string
}

