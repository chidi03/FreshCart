variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "backend_subnet_name" {
  description = "Name of the backend subnet"
  type        = string
}

variable "backend_subnet_cidr" {
  description = "CIDR range for the backend subnet"
  type        = string
}

variable "secondary_subnet_name" {
  description = "Name of the secondary subnet"
  type        = string
}

variable "secondary_subnet_cidr" {
  description = "CIDR range for the secondary subnet"
  type        = string
}
