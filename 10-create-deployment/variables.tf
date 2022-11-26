variable "project_name" {
  default = "best-10"
}
variable "environment" {}

variable "cloudflare_zone_id" {}

variable "region" {
  default = "asia-northeast1"
}
variable "rails_env" {}

variable "domain_name" {}
variable "subdomain_name" {}

# Cloud SQL
variable "cloud_sql_machine_type" {}
variable "database_version" {
  description = "Cloud SQL database version"
}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}

variable "rails_master_key" {}

variable "google_credential" {}

variable "tls_certificate" {}
variable "tls_certificate_key" {}

variable "sentry_dsn" {}

variable "default_admin_username" {}
variable "default_admin_password" {}

# CloudFlare
variable "cloudflare_api_email" {}
variable "cloudflare_api_key" {}