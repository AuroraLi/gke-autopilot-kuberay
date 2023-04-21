resource "google_compute_network" "vpc_network" {
  name = "vpc-network"
  project = local.project_id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-gke" {
  name          = "gke-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  project = local.project_id
  network       = google_compute_network.vpc_network.id
  secondary_ip_range = [{
    range_name    = "pod"
    ip_cidr_range = var.ip_range_pods
  },
  {
    range_name    = "service"
    ip_cidr_range = var.ip_range_services
  }]
}

resource "google_compute_router" "router" {
  project = local.project_id
  name    = "nat-router"
  network = google_compute_network.vpc_network.name
  region  = var.region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = local.project_id
  region                             = var.region
  router                             = google_compute_router.router.name
  name                               = "nat-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}