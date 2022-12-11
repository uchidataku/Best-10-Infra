variable "project_name" {}
variable "environment" {}
variable "rails_env" {}
variable "app_image_url" {}
variable "global_ip" {}
variable "domain_name" {}
#variable "subdomain_name" {}

# Database
variable "database_host" {}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}

variable "rails_master_key" {}

variable "tls_certificate" {}
variable "tls_certificate_key" {}

variable "sentry_dsn" {}

# Admin
variable "default_admin_username" {}
variable "default_admin_password" {}
