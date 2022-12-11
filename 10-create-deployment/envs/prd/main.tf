terraform {
  required_version = "~> 1.3.5"

  backend "remote" {
    organization = "uchidataku"

    workspaces {
      name = "best-10-prd"
    }
  }
}

module "prd" {
  source = "../../"

  project_name = var.project_name
  region       = var.region
  environment  = "prd"
  rails_env    = "production"

  cloudflare_zone_id = var.cloudflare_zone_id

  domain_name    = var.domain_name
#  subdomain_name = var.subdomain_name

  # Cloud SQL
  cloud_sql_machine_type = var.cloud_sql_machine_type
  database_version       = var.database_version
  database_name          = var.database_name
  database_username      = var.database_username
  database_password      = var.database_password

  rails_master_key   = var.rails_master_key
  google_credential = var.google_credential

  tls_certificate     = var.tls_certificate
  tls_certificate_key = var.tls_certificate_key

  sentry_dsn = var.sentry_dsn

  default_admin_username = var.default_admin_username
  default_admin_password = var.default_admin_password

  cloudflare_api_email = var.cloudflare_api_email
  cloudflare_api_key = var.cloudflare_api_key
}