variable "gcp_region" {
  type = string
}

variable "health_checks" {
  type = string
}

resource "google_compute_target_pool" "target_pool" {
  name = "instance-pool"
  region = var.gcp_region

  health_checks = [var.health_checks]
}

output "target_pool_id" {
  value = google_compute_target_pool.target_pool.id
}