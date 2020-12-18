variable "gcp_region" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "gcp_subnet" {
  type = string
}

variable "bucket_uri" {
  type = string
}

variable "sql_connection" {
  type = string
}

resource "google_compute_instance_template" "instance_template" {
  name = "grafana-template"
  region = var.gcp_region
  tags = ["grafana", "all"]

  labels = {
    instance = "grafana"
  }

  machine_type = "f1-micro"
  can_ip_forward = false

  scheduling {
    automatic_restart = false
    on_host_maintenance = "TERMINATE"
    preemptible = true
  }

  service_account {
    scopes = ["storage-ro", "sql-admin"]
  }

  disk {
    source_image = data.google_compute_image.image.id
  }

  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network = var.gcp_network
    subnetwork = var.gcp_subnet
  }

  metadata_startup_script = <<EOF
    sudo cat /dev/zero | sudo ssh-keygen -q -N "" > /dev/null
    while true; do sleep 1 && sudo gsutil cp ${var.bucket_uri} /root/ && break; done
    sudo cat /root/id_rsa.pub >> /root/.ssh/authorized_keys

    curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
    sudo bash install-logging-agent.sh

    sudo apt install software-properties-common nginx git wget -y
    wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
    sudo chmod +x cloud_sql_proxy
    sudo /cloud_sql_proxy -instances=${var.sql_connection}=tcp:127.0.0.1:3306 &

    sudo apt-add-repository 'deb https://packages.grafana.com/oss/deb stable main'
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo apt update
    sudo apt install grafana -y

    sudo crontab -l | { cat; echo "*/1 0 0 0 0 cd /grafana/ && sudo ansible-playbook -i ./gcp.yml ./main.yml"; } | sudo crontab -
  EOF
}

data "google_compute_image" "image" {
  family  = "debian-10"
  project = "debian-cloud"
}

output "instance_template_id" {
  value = google_compute_instance_template.instance_template.id
}