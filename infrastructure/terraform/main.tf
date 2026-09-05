module "network" {
  source = "./modules/network"

  network_name          = "freshcart-${var.environment}-vpc"
  region                = var.region
  backend_subnet_name   = "freshcart-${var.environment}-backend-subnet"
  backend_subnet_cidr   = "10.10.0.0/24"
  secondary_subnet_name = "freshcart-${var.environment}-secondary-subnet"
  secondary_subnet_cidr = "10.20.0.0/24"
}


resource "google_compute_router" "nat_router" {
  name    = "freshcart-${var.environment}-router"
  region  = var.region
  network = module.network.network_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "freshcart-${var.environment}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = module.network.backend_subnet_id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_service_account" "backend_runtime" {
  account_id   = "freshcart-${var.environment}-runtime"
  display_name = "FreshCart ${var.environment} backend runtime"
}

resource "google_artifact_registry_repository_iam_member" "backend_image_reader" {
  project    = var.project_id
  location   = var.region
  repository = var.artifact_registry_repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.backend_runtime.email}"
}



resource "google_compute_firewall" "allow_health_checks" {
  name    = "freshcart-${var.environment}-allow-health-checks"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["freshcart-backend"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "freshcart-${var.environment}-allow-internal"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "3000"]
  }

  source_ranges = [
    "10.10.0.0/24",
    "10.20.0.0/24"
  ]

  target_tags = ["freshcart-backend"]
}



resource "google_compute_instance_template" "backend" {

  lifecycle {
    create_before_destroy = true
  }

  name_prefix  = "freshcart-${var.environment}-backend-"
  machine_type = var.machine_type

  tags = ["freshcart-backend"]

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = module.network.backend_subnet_id
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    container_image = var.container_image
    backend_port    = var.backend_port
  })

  service_account {
    email = google_service_account.backend_runtime.email

    scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [
    google_artifact_registry_repository_iam_member.backend_image_reader
  ]
}


resource "google_compute_region_instance_group_manager" "backend" {
  name               = "freshcart-${var.environment}-backend-mig"
  region             = var.region
  base_instance_name = "freshcart-backend"

  version {
    instance_template = google_compute_instance_template.backend.id
  }

  target_size = 1

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 0
  }


  named_port {
    name = "http"
    port = 80
  }
}



resource "google_compute_health_check" "backend" {
  name = "freshcart-${var.environment}-health-check"

  http_health_check {
    port         = 80
    request_path = "/healthz"
  }
}



resource "google_compute_backend_service" "backend" {
  name                  = "freshcart-${var.environment}-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.backend.id]

  backend {
    group = google_compute_region_instance_group_manager.backend.instance_group
  }
}



resource "google_compute_url_map" "backend" {
  name            = "freshcart-${var.environment}-url-map"
  default_service = google_compute_backend_service.backend.id
}



resource "google_compute_target_http_proxy" "backend" {
  name    = "freshcart-${var.environment}-http-proxy"
  url_map = google_compute_url_map.backend.id
}



resource "google_compute_global_address" "backend" {
  name = "freshcart-${var.environment}-lb-ip"
}


resource "google_compute_global_forwarding_rule" "backend" {
  name                  = "freshcart-${var.environment}-forwarding-rule"
  target                = google_compute_target_http_proxy.backend.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.backend.address
}



resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "freshcart-${var.environment}-allow-iap-ssh"
  network = module.network.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = ["freshcart-backend"]
}
