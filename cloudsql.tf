locals {
    env		     = "development"
    db_version       = "POSTGRES_14"
    db_name          = "wppgres01"
    db_tier          = "db-g1-small"
    region           = "europe-west3"
    zone             = "europe-west3-a"
    project          = "coen-asil-carlin"
    vpc              = "wordpress-vpc"
    av_type	     = "ZONAL"
    bkp_ena	     = "true" 
    bkp_ret	     = "1"
    bkp_loc	     = "eu"
    bkp_start	     = "02:00"
    disk_autoresz    = "false"
    disk_size        = "10"
    disk_type        = "PD_HDD"
    maint_day	     = "7"
    maint_hour	     = "2"

}

data "google_secret_manager_secret_version" "user_password" {
  secret = "sql-db-user-password"
}

resource "google_sql_database_instance" "wppgres01" {
  database_version   = local.db_version
  name               = local.db_name

  settings {
    activation_policy = "ALWAYS"
    availability_type = local.av_type

    backup_configuration {
      backup_retention_settings {
        retained_backups = local.bkp_ret
        retention_unit   = "COUNT"
      }

      enabled                        = local.bkp_ena
      location                       = local.bkp_loc
      start_time                     = local.bkp_start
      transaction_log_retention_days = 7
    }

    disk_autoresize       = local.disk_autoresz
    disk_autoresize_limit = 0
    disk_size             = local.disk_size
    disk_type             = local.disk_type

    insights_config {
      query_insights_enabled = true
      query_string_length    = 1024
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.wordpress-vpc.id
      enable_private_path_for_google_cloud_services = true
    }

    maintenance_window {
      day  = 1
      hour = 0
    }

    location_preference {
      zone = local.zone
    }

    pricing_plan = "PER_USE"
    tier         = local.db_tier

    user_labels = {
      env = local.env 
    }
}

depends_on = [google_service_networking_connection.wordpress-vpc]

}


resource "google_sql_database" "database" {
  name     = "wordpress"
  instance = google_sql_database_instance.wppgres01.name
}

resource "google_sql_user" "sql_user" {
  instance = google_sql_database_instance.wppgres01.name
  name     = "wordpress-db"
  project  = local.project
  password = sensitive(data.google_secret_manager_secret_version.user_password.secret_data)
}

