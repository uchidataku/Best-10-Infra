terraform {
  required_providers {
    google = {
      version = "~> 3.24"
    }
  }
}


data "google_container_registry_image" "app_image" {
  name = "${var.project_name}-${var.environment}/app"
  tag  = "latest"
}