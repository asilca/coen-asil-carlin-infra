locals {
  project_id    = "coen-asil-carlin"
  vpc_name      = "wordpress-vpc"
  subnet_region = "europe-west3"
  subnet_range  = "192.168.0.0/20"
}

resource "google_compute_network" "wordpress-vpc" {
  project                 = local.project_id
  name                    = local.vpc_name
}

resource "google_compute_subnetwork" "backstage_subnets" {
  depends_on = [
    google_compute_network.wordpress-vpc
  ]

  count         = 2

  name          = "backstage-subnet-${count.index + 1}"

  ip_cidr_range = cidrsubnets(local.subnet_range, 4, 2)[count.index]
  region        = local.subnet_region
  network       = google_compute_network.wordpress-vpc.id

  # dynamic "secondary_ip_range" {
  #   for_each = var.set_secondary_range == false ? toset([]) : toset([1])
  #   content {
  #       range_name    = "backstage-subnet-secondary-${count.index + 1}"
  #       ip_cidr_range = var.secondary_range
  #     }
  #   }
}

resource "google_compute_global_address" "wordpress-vpc" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.wordpress-vpc.id
}

resource "google_service_networking_connection" "wordpress-vpc" {
  network                 = google_compute_network.wordpress-vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.wordpress-vpc.name]
}
