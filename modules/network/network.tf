variable "gcp_subnet" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "subnet_cidr" {
  type = string
  default = "10.0.0.0/24"
}

variable "gcp_region" {
  type = string
}

resource "google_compute_network" "network" {
  name = var.gcp_network
  auto_create_subnetworks = "false"
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "subnet" {
  name = var.gcp_subnet
  ip_cidr_range = var.subnet_cidr
  network = google_compute_network.network.id
  region = var.gcp_region

  log_config {
    aggregation_interval = "INTERVAL_30_SEC"
    flow_sampling = 0.25
    metadata = "INCLUDE_ALL_METADATA"
  }
}

output "network_id" {
  value = google_compute_network.network.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}