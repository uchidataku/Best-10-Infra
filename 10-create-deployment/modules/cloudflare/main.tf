terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.7"
    }
  }
}

resource "cloudflare_record" "api" {
  name    = var.hostname
  value   = var.global_ip
  type    = "A"
  zone_id = var.zone_id
  proxied = true
}