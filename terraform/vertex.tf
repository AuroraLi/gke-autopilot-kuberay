resource "google_notebooks_instance" "instance" {
  name = "notebooks-instance"
  location = "us-central1-a"
  machine_type = "e2-medium"
  metadata = {
    proxy-mode = "service_account"
    terraform  = "true"
  }
  container_image {
    repository = "gcr.io/deeplearning-platform-release/base-cpu"
    tag = "latest"
  }
  network = google_compute_network.vpc_network.id
  subnet = google_compute_subnetwork.network-gke.id
}

resource "google_service_account" "notebook_service_account" {
  account_id   = "notebook"
  display_name = "reading and editing certificate "
  project = local.project_id
}

resource "google_project_iam_member" "nb" {
  project = local.project_id
  role    = "roles/certificatemanager.editor"
  member  = "serviceAccount:${google_service_account.notebook_service_account.email}"
}
