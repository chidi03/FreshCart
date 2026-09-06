variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "chidi-cloud-security-lab"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "Backend VM machine type"
  type        = string
  default     = "e2-micro"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}


variable "container_image" {
  description = "Container image for the FreshCart checkout API"
  type        = string
}

variable "backend_port" {
  description = "Port exposed by the checkout API container"
  type        = number
  default     = 3000
}


variable "artifact_registry_repository" {
  description = "Artifact Registry repository containing the checkout API image"
  type        = string
  default     = "freshcart-images"
}
