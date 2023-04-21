resource "random_string" "random" {
  length           = 4
  special          = false
}


resource "google_storage_bucket" "auto-expire" {
    project = google_project.gke_project.project_id
  name          = "${local.project_id}"
  location      = "US"
  force_destroy = true

  public_access_prevention = "enforced"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.auto-expire.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_project.gke_project.number}-compute@developer.gserviceaccount.com"
}


resource "google_storage_bucket_iam_member" "nb_gcs" {
    bucket = google_storage_bucket.auto-expire.name
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.notebook_service_account.email}"
}




resource "google_service_account" "gke_account" {
  account_id   = "gke-wi"
  display_name = "gke workload identity"
  project = local.project_id
}

resource "google_storage_bucket_iam_member" "gke_member" {
  bucket = google_storage_bucket.auto-expire.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gke_account.email}"
}




resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.gke_account.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.project_id}.svc.id.goog[default/worker]" ,
  ]
}

