variable "gcp_region" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "db_user" {
  type = string
  default = "db_user"
}

variable "db_name" {
  type = string
  default = "db_name"
}

resource "random_string" "db_id" {
  length  = 4
  special = false
  upper = false
}

resource "random_string" "pass" {
  length  = 10
  special = false
}

resource "google_sql_database_instance" "instance" {
  name   = "database-instance-${random_string.db_id.result}"
  region = var.gcp_region
  settings {
    tier = "db-g1-small"
  }

  deletion_protection  = "false"
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_string.pass.result
}

output "sql_connection" {
  value = google_sql_database_instance.instance.connection_name
}

output "sql_user_password" {
  value = google_sql_user.user.password
}

output "sql_user_name" {
  value = google_sql_user.user.name
}

output "sql_database" {
  value = google_sql_database.database.name
}