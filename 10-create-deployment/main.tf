terraform {
  required_version = "~> 1.3.5"

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.7"
    }

    google = {
      version = "~> 3.24"
    }

    kubernetes = {
      version = "~> 1.11"
    }

    random = {
      version = "~> 2.2"
    }
  }
}

/*
  Providers
*/
provider "google" {
  credentials = var.google_credential
  region      = var.region
  zone        = "${var.region}-a"
}

data "google_client_config" "current" {}
data "google_container_cluster" "gke" {
  name = "${var.project_name}-cluster"
}

provider "kubernetes" {
  load_config_file = false

  host                   = data.google_container_cluster.gke.endpoint
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "cloudflare" {
  email   = var.cloudflare_api_email
  api_key = var.cloudflare_api_key
}

/*
  Modules
*/
module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
}

module "cloudflare" {
  source = "./modules/cloudflare"

  zone_id        = var.cloudflare_zone_id
#  subdomain_name = var.subdomain_name
  domain_name = var.domain_name
  global_ip      = tostring(module.networking.global_ip.address)
}

module "sql" {
  source = "./modules/sql"

  project_name           = var.project_name
  environment            = var.environment
  vpc                    = module.networking.vpc
  cloud_sql_machine_type = var.cloud_sql_machine_type
  database_version       = var.database_version
  database_name          = var.database_name
  database_username      = var.database_username
  database_password      = var.database_password
}

module "gcr" {
  source = "./modules/gcr"

  project_name = var.project_name
  environment  = var.environment
}

module "k8s" {
  source = "./modules/k8s"

  project_name = var.project_name
  environment  = var.environment
  rails_env    = var.rails_env

  app_image_url = module.gcr.app_image_url
  global_ip     = module.networking.global_ip

  domain_name    = var.domain_name
#  subdomain_name = var.subdomain_name

  database_host     = module.sql.database_host
  database_name     = var.database_name
  database_username = var.database_username
  database_password = var.database_password

  rails_master_key    = var.rails_master_key

  tls_certificate     = var.tls_certificate
  tls_certificate_key = var.tls_certificate_key

  sentry_dsn = var.sentry_dsn

  default_admin_username = var.default_admin_username
  default_admin_password = var.default_admin_password
}