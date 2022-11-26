variable "project_name" {}

variable "vpc" {}

# GKE
variable "preemptible" {}
variable "initial_node_count" {}
variable "min_node_count" {}
variable "max_node_count" {}
variable "node_machine_type" {}