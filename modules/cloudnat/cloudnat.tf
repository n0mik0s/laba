variable "gcp_network" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_subnet" {
    type = string
}

resource "google_compute_router" "router" {
  name    = "router"
  region  = var.gcp_region
  network = var.gcp_network

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name = "nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name = var.gcp_subnet
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}