resource "google_compute_network" "vpc" {
  auto_create_subnetworks = true
  name                    = var.project_name
}