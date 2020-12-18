variable "target_http_proxy_id" {
  type = string
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  provider = google-beta
  name = "forwarding-rule"
  ip_protocol = "TCP"
  target = var.target_http_proxy_id
  port_range = "80"
}

output "forwarding_rule_id" {
  value = google_compute_global_forwarding_rule.forwarding_rule.id
}