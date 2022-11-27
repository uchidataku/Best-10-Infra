data "google_compute_zones" "available" {}

resource "google_container_cluster" "primary" {
  name     = "${var.project_name}-cluster"
  location = data.google_compute_zones.available.names[0]
  network  = var.vpc.self_link

  remove_default_node_pool = true
  initial_node_count       = var.initial_node_count

  node_config {
    preemptible = var.preemptible

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  ip_allocation_policy {}
  network_policy {
    enabled = true
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name               = "${var.project_name}-node-pool"
  location           = data.google_compute_zones.available.names[0]
  cluster            = google_container_cluster.primary.name
  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.node_machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}