output "database_host" {
  value = google_sql_database_instance.sql.private_ip_address
}