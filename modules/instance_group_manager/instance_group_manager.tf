variable "gcp_zone" {
  type = string
}

variable "instance_template_id" {
  type = string
}

variable "target_pools" {
  type = string
}

variable "health_check_id" {
  type = string
}

resource "google_compute_instance_group_manager" "appserver" {
  name = "appserver-igm"

  base_instance_name = "app"
  zone = var.gcp_zone

  version {
    instance_template = var.instance_template_id
  }

  target_pools = [var.target_pools]

  named_port {
    name = "grafana"
    port = 80
  }

  auto_healing_policies {
    health_check = var.health_check_id
    initial_delay_sec = 60
  }
}

output "instance_group_manager_id" {
  value = google_compute_instance_group_manager.appserver.id
}

output "instance_group_manager_ig" {
  value = google_compute_instance_group_manager.appserver.instance_group
}