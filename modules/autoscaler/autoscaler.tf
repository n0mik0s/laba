variable "gcp_zone" {
  type = string
}

variable "instance_group_manager_id" {
  type = string
}

resource "google_compute_autoscaler" "autoscaler" {
  name   = "autoscaler"
  zone   = var.gcp_zone
  target = var.instance_group_manager_id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 300

    load_balancing_utilization {
      target = 0.75
    }

    cpu_utilization {
      target = 0.7
    }
  }
}