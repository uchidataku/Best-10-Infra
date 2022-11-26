terraform {
  required_providers {
    google = {
      version = "~> 3.24"
    }
  }
}

data "google_compute_network" "vpc" {
  name = var.project_name
}

resource "google_compute_global_address" "global_ip" {
  name = "${var.project_name}-${var.environment}-global-ip"
}