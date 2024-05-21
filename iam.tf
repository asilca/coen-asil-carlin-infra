locals {
  project_iam = "coen-asil-carlin"
  gke_cluster = "testclus01"
}

resource "google_service_account" "wordpress_sa" {
  account_id   = "wordpress-sa"
  description  = "Service account for accessing Cloud SQL DB from within GKE cluster"
  disabled     = "false"
  display_name = "wordpress-sa"
}

resource "google_project_iam_member" "wordpress_sa_iam_role" {
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.wordpress_sa.email}"
  project = local.project_iam
}

resource "google_service_account_iam_binding" "wordpress_sa_iam_gke" {
  service_account_id = google_service_account.wordpress_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${local.project_iam}.svc.id.goog[wordpress/wordpress-sa]"
  ]

}
