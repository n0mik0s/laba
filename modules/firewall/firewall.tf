variable "gcp_network_id" {
  type = string
}

resource "google_compute_firewall" "fw_rule_all_ssh" {
  name    = "all"
  network = var.gcp_network_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["all"]
}

resource "google_compute_firewall" "fw_rule_grafana_www" {
  name    = "grafana"
  network = var.gcp_network_id

  allow {
    protocol = "tcp"
    ports = ["80"]
  }

  target_tags = ["grafana"]
}