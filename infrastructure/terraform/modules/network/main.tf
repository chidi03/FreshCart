resource "google_compute_network" "this" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "backend" {
  name          = var.backend_subnet_name
  ip_cidr_range = var.backend_subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}

resource "google_compute_subnetwork" "secondary" {
  name          = var.secondary_subnet_name
  ip_cidr_range = var.secondary_subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}
