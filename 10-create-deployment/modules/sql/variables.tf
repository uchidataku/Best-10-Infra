variable "project_name" {}
variable "environment" {}
variable "vpc" {}

# Cloud SQL
variable "cloud_sql_machine_type" {}
variable "database_version" {
  description = "Cloud SQL database version"
}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}