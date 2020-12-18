resource "google_compute_http_health_check" "health_check" {
  name         = "health-check"
  request_path = "/"

  timeout_sec        = 2
  check_interval_sec = 10
  port = 80

  healthy_threshold = 1
  unhealthy_threshold = 5
}

output "http_health_check_id" {
  value = google_compute_http_health_check.health_check.id
}