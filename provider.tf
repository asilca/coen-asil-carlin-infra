provider "google" {
  project = "coen-asil-carlin"
  region  = "europe-west3"
}

provider "google-beta" {
  project = "coen-asil-carlin"
  region  = "europe-west3"
}

terraform {
  required_providers {
    google = {
      version = "5.19.0"
    }
    google-beta = {
      version = "5.19.0"
    }
  }

  backend "gcs" {
    bucket = "coen-asil-carlin-backstage-terraform"
    prefix = "coen-asil-carlin"
  }
}
