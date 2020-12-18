variable "backend_service_id" {
  type = string
}

resource "google_compute_url_map" "urlmap" {
  name = "urlmap"
  default_service = var.backend_service_id
}

output "url_map_id" {
  value = google_compute_url_map.urlmap.id
}