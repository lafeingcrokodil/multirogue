resource "google_service_account" "production" {
  account_id = "production"
}

resource "google_service_account_iam_member" "production_users" {
  service_account_id = google_service_account.production.id
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.github_actions.member
}

resource "google_cloud_run_domain_mapping" "production" {
  location = var.region
  name     = "multirogue.lafeingcrokodil.com"
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = "production"
  }
}
