terraform {
  required_version = "~> 1.0.0"

  backend "remote" {
    organization = "uchidataku"

    workspaces {
      name = "best-10-cluster"
    }
  }
}

/*
  Providers
*/
provider "google" {
  credentials = var.google_credential
  region      = var.region
  project     = var.project_name
}

/*
  Modules
*/
module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

module "gke" {
  source       = "./modules/gke"
  project_name = var.project_name
  vpc          = module.networking.vpc

  preemptible        = var.preemptible
  initial_node_count = var.initial_node_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  node_machine_type  = var.node_machine_type
}