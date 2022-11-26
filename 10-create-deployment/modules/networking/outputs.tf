output "vpc" {
  value = data.google_compute_network.vpc
}

output "global_ip" {
  value = google_compute_global_address.global_ip
}