terraform {
  backend "gcs" {
    bucket  = "terraform-remote-states-test-298314"
    prefix  = "terraform/state"
  }
}

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

module "target_pool" {
  source = "./modules/target_pool"
  gcp_region = var.gcp_region
  health_checks = module.http_health_check.http_health_check_id
}

module "instance_template" {
  source = "./modules/instance_template"
  gcp_region = var.gcp_region
  gcp_network = module.network.network_id
  gcp_subnet = module.network.subnet_id
  bucket_uri = module.ansible.bucket_uri
  sql_connection = module.cloudsql.sql_connection
}

module "instance_group_manager" {
  source = "./modules/instance_group_manager"
  instance_template_id = module.instance_template.instance_template_id
  gcp_zone = var.gcp_zone
  target_pools = module.target_pool.target_pool_id
  health_check_id = module.http_health_check.http_health_check_id
}

module "autoscaler" {
  source = "./modules/autoscaler"
  gcp_zone = var.gcp_zone
  instance_group_manager_id = module.instance_group_manager.instance_group_manager_id
}

module "http_health_check" {
  source = "./modules/http_health_check"
}

module "backend_service" {
  source = "./modules/backend-service"
  health_check_id = module.http_health_check.http_health_check_id
  mig = module.instance_group_manager.instance_group_manager_ig
}

module "forwarding_rule" {
  source = "./modules/forwarding_rule"
  target_http_proxy_id = module.target_http_proxy.target_http_proxy_id
}

module "url_map" {
  source = "./modules/url_map"
  backend_service_id = module.backend_service.backend_service_id
}

module "target_http_proxy" {
  source = "./modules/target_http_proxy"
  url_map_id = module.url_map.url_map_id
}