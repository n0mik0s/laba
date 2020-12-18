variable "gcp_project" {
  type = string
}
variable "gcp_region" {
  type = string
  default = "us-central1"
}

variable "gcp_zone" {
  type = string
  default = "us-central1-a"
}

variable "gcp_subnet" {
  type = string
}

variable "gcp_network" {
  type = string
}

variable "gcp_sql_db_name" {
  type = string
}

variable "gcp_sql_user_name" {
  type = string
}