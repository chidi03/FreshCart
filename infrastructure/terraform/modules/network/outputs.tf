output "network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "backend_subnet_id" {
  description = "ID of the backend subnet"
  value       = google_compute_subnetwork.backend.id
}

output "backend_subnet_name" {
  description = "Name of the backend subnet"
  value       = google_compute_subnetwork.backend.name
}

output "secondary_subnet_id" {
  description = "ID of the secondary subnet"
  value       = google_compute_subnetwork.secondary.id
}
