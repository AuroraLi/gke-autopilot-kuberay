/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "simple-regional-private"
}

data "google_client_config" "default" {}


module "gke" {
  source                    = "terraform-google-modules/kubernetes-engine/google//modules/beta-autopilot-private-cluster"
  project_id                = local.project_id
  name                      = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  regional                  = true
  region                    = var.region
  network                   = google_compute_network.vpc_network.name
  subnetwork                = google_compute_subnetwork.network-gke.name
  ip_range_pods             = "pod"
  ip_range_services         = "service"
  create_service_account    = false
  service_account           = "${google_project.gke_project.number}-compute@developer.gserviceaccount.com"
  enable_private_endpoint   = false
  enable_private_nodes      = true
  master_ipv4_cidr_block    = "172.16.0.0/28"
  kubernetes_version = "latest"
  add_cluster_firewall_rules = true
  firewall_inbound_ports = ["10250"]
  identity_namespace = "${local.project_id}.svc.id.goog"
  enable_vertical_pod_autoscaling = true

  master_authorized_networks = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    },
  ]
}


resource "google_project_iam_member" "gke-iam" {
  project = local.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_project.gke_project.number}-compute@developer.gserviceaccount.com"
}
