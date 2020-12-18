variable "url_map_id" {
  type = string
}

resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = "target-http-proxy"
  url_map = var.url_map_id
}

output "target_http_proxy_id" {
  value = google_compute_target_http_proxy.target_http_proxy.id
}