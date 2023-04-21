resource "google_project" "gke_project" {
  name       = "kuberay"
  project_id = var.project_id
  folder_id  = var.folder_id
  billing_account = var.billing_account
}


locals {
    project_id = split("/","${google_project.gke_project.id}")[1]
}

resource "google_project_service" "gke_api_googleapis_com" {
  project = google_project.gke_project.id
  service = "container.googleapis.com"
}
resource "google_project_service" "run_googleapis_com" {
  project = google_project.gke_project.id
  service = "run.googleapis.com"
}
resource "google_project_service" "iam_googleapis_com" {
  project = google_project.gke_project.id
  service = "iam.googleapis.com"
}
resource "google_project_service" "compute_googleapis_com" {
  project = google_project.gke_project.id
  service = "compute.googleapis.com"
}
resource "google_project_service" "containerregistry_googleapis_com" {
  project = google_project.gke_project.id
  service = "containerregistry.googleapis.com"
}
resource "google_project_service" "publicca_googleapis_com" {
  project = google_project.gke_project.id
  service = "publicca.googleapis.com"
}


resource "google_project_service" "certmanager_googleapis_com" {
  project = google_project.gke_project.id
  service = "certificatemanager.googleapis.com"
}




resource "google_project_service" "cloudresourcemanager_googleapis_com" {
  project = google_project.gke_project.id
  service = "cloudresourcemanager.googleapis.com"
}


resource "google_project_service" "serviceusage_googleapis_com" {
  project = google_project.gke_project.id
  service = "serviceusage.googleapis.com"
}


resource "google_project_service" "notebooks_googleapis_com" {
  project = google_project.gke_project.id
  service = "notebooks.googleapis.com"
}


