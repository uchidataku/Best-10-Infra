variable "project_name" {}
variable "region" {
  default = "asia-northeast1"
}

# GKE
variable "preemptible" {}
variable "initial_node_count" {}
variable "min_node_count" {}
variable "max_node_count" {}
variable "node_machine_type" {}

variable "google_credential" {}