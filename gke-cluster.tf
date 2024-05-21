locals {
    gkeName          = "testclus01"
    nodePool         = "pool01"
    gke_machineType  = "e2-medium"
    gke_region       = "europe-west3"
}

resource "google_container_cluster" "gke-cluster" {
  name     = local.gkeName
  location = local.gke_region
  network  = google_compute_network.wordpress-vpc.id
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  logging_service          = "logging.googleapis.com/kubernetes"

  workload_identity_config {
    workload_pool = "coen-asil-carlin.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = local.nodePool
  location   = local.gke_region
  cluster    = google_container_cluster.gke-cluster.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = local.gke_machineType

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = default
    oauth_scopes    = [
     "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}