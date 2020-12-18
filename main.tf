provider "google" {
  region  = var.gcp_region
  project = var.gcp_project
}

module "network" {
  source = "./modules/network"
  gcp_region = var.gcp_region
  gcp_network = var.gcp_network
  gcp_subnet = var.gcp_subnet
}

module "firewall" {
  source = "./modules/firewall"
  gcp_network_id = module.network.network_id
}

module "cloudnat" {
  source = "./modules/cloudnat"
  gcp_network = module.network.network_id
  gcp_region = var.gcp_region
  gcp_subnet = module.network.subnet_id
}

module "cloudsql" {
  source = "./modules/cloudsql"
  gcp_network = module.network.network_id
  gcp_region = var.gcp_region
}

module "ansible" {
  source = "./modules/ansible"
  gcp_zone = var.gcp_zone
  gcp_project = var.gcp_project
  gcp_network = module.network.network_id
  gcp_subnet = module.network.subnet_id
  sql_connection = module.cloudsql.sql_connection
  sql_user_password = module.cloudsql.sql_user_password
  sql_user_name = module.cloudsql.sql_user_name
  sql_database = module.cloudsql.sql_database
}