resource "google_sql_database_instance" "postgres" {
  name             = "verikyc-db-${var.environment}"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  settings {
    tier = var.tier

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

resource "google_sql_user" "user" {
  name     = var.database_user
  instance = google_sql_database_instance.postgres.name
  password = var.database_password
  project  = var.project_id
}
