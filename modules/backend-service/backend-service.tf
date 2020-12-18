variable "health_check_id" {
  type = string
}

variable "mig" {
  type = string
}

resource "google_compute_backend_service" "backend_service" {
  name = "backend-service"
  health_checks = [var.health_check_id]
  enable_cdn = true
  timeout_sec = 30
  connection_draining_timeout_sec = 10
  port_name = "grafana"
  protocol = "HTTP"

  backend {
    group = var.mig
  }

  log_config {
    enable = true
  }
}

output "backend_service_id" {
  value = google_compute_backend_service.backend_service.id
}