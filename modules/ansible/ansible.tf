variable "gcp_zone" {
  type = string
}

variable "gcp_project" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "gcp_subnet" {
  type = string
}

variable "sql_connection" {
  type = string
}

variable "sql_user_password" {
  type = string
}

variable "sql_user_name" {
  type = string
}

variable "sql_database" {
  type = string
}

locals {
  sa_key = base64decode(google_service_account_key.ansible-ro-key.private_key)
}

resource "random_string" "random_sa" {
  length  = 5
  special = false
  upper = false
}

resource "random_string" "random_role" {
  length  = 5
  special = false
  upper = false
}

resource "google_service_account" "ansible-ro-sa" {
  account_id   = "ansible-ro-sa-${random_string.random_sa.result}"
}

resource "google_service_account_key" "ansible-ro-key" {
  service_account_id = google_service_account.ansible-ro-sa.name
}

resource "google_project_iam_custom_role" "ansible-ro-role" {
  role_id = "ansible_ro_${random_string.random_role.result}"

  title = "Ansible API (RO)"

  permissions = [
    "compute.instances.list",
    "compute.instances.get",
  ]
}

resource "google_project_iam_binding" "ansible-ro-binding" {
  role = "projects/${var.gcp_project}/roles/${google_project_iam_custom_role.ansible-ro-role.role_id}"

  members = [
    "serviceAccount:${google_service_account.ansible-ro-sa.email}",
  ]
}

resource "google_storage_bucket" "ansible" {
  name = "ansible-${var.gcp_project}"
  project = var.gcp_project
  location = "US-CENTRAL1"
  force_destroy = true
}

resource "google_storage_bucket_object" "key" {
  name   = "key.json"
  content = local.sa_key
  bucket = google_storage_bucket.ansible.name
}

resource "google_compute_instance" "server" {
  name = "ansible-server"
  machine_type = "e2-medium"
  zone = var.gcp_zone

  service_account {
    scopes = ["storage-rw"]
  }

  allow_stopping_for_update = true
  deletion_protection = false
  tags = ["ansible", "all"]

  labels = {
    staging = "test"
    instance = "ansible"
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = var.gcp_network
    subnetwork = var.gcp_subnet
  }

  metadata_startup_script = <<EOF
    sudo cat /dev/zero | sudo ssh-keygen -q -N "" > /dev/null
    sudo gsutil cp /root/.ssh/id_rsa.pub gs://ansible-${var.gcp_project}/

    sudo apt install software-properties-common python-pip git -y

    sudo apt-add-repository 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main'
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    sudo apt update
    sudo pip install requests google-auth
    sudo apt install ansible -y
    sudo ansible-galaxy collection install google.cloud

    sudo git clone https://github.com/n0mik0s/grafana.git /grafana/
    sudo chmod 755 -R /grafana
    sudo gsutil cp gs://ansible-${var.gcp_project}/${google_storage_bucket_object.key.name} /grafana/

    sudo sed -i 's/ZONE/${var.gcp_zone}/g' /grafana/gcp.yml
    sudo sed -i 's/PROJECT/${var.gcp_project}/g' /grafana/gcp.yml
    sudo sed -i 's/BUCKET_PUB_KEY_URI/gs\:\/\/ansible-${var.gcp_project}\/id_rsa.pub/g' /grafana/roles/grafana/templates/pub_check.sh

    sudo echo 'sql_connection: ${var.sql_connection}' >> /grafana/group_vars/all
    sudo echo 'sql_user_password: ${var.sql_user_password}' >> /grafana/group_vars/all
    sudo echo 'sql_user_name: ${var.sql_user_name}' >> /grafana/group_vars/all
    sudo echo 'sql_database: ${var.sql_database}' >> /grafana/group_vars/all
  EOF
}

output "bucket_uri" {
  value = "gs://ansible-${var.gcp_project}/id_rsa.pub"
}