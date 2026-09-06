output "load_balancer_ip" {
  description = "Public IP address of the load balancer"
  value       = google_compute_global_address.backend.address
}

output "backend_instance_group" {
  description = "Backend managed instance group"
  value       = google_compute_region_instance_group_manager.backend.instance_group
}

output "backend_instance_id" {
  description = "Backend managed instance group identifier"
  value       = google_compute_region_instance_group_manager.backend.id
}


output "backend_instance_template" {
  description = "Backend instance template ID"
  value       = google_compute_instance_template.backend.id
}

output "deployed_image" {
  description = "Exact container image configured for this environment"
  value       = var.container_image
}
