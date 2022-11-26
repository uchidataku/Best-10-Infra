terraform {
  required_providers {
    google = {
      version = "~> 3.24"
    }
  }
}

resource "google_compute_global_address" "private_address" {
  name          = "${var.project_name}-${var.environment}-sql"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = var.vpc.id
  prefix_length = 16 # Google公式が16をおすすめしてる
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc.id
  reserved_peering_ranges = [google_compute_global_address.private_address.name]
  service                 = "servicenetworking.googleapis.com"

  lifecycle {
    ignore_changes = [reserved_peering_ranges]
  }
}

// Cloud SQLのインスタンス名は削除から最大1週間再利用できないため乱数を使う
resource "random_id" "db_suffix" {
  byte_length = 5
}

resource "google_sql_database_instance" "sql" {
  name = "${var.project_name}-${var.environment}-${random_id.db_suffix.hex}"

  database_version = var.database_version

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    tier = var.cloud_sql_machine_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc.id
    }

    backup_configuration {
      enabled = true
    }
  }
}

resource "google_sql_database" "database" {
  instance = google_sql_database_instance.sql.name
  name     = var.database_name
}

resource "google_sql_user" "user" {
  instance = google_sql_database_instance.sql.name
  name     = var.database_username
  password = var.database_password
}