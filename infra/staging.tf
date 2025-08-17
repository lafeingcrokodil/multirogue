resource "google_service_account" "staging" {
  account_id = "staging"
}

resource "google_service_account_iam_member" "staging_users" {
  service_account_id = google_service_account.staging.id
  role               = "roles/iam.serviceAccountUser"
  member             = google_service_account.github_actions.member
}

resource "google_cloud_run_domain_mapping" "staging" {
  location = var.region
  name     = "staging.multirogue.lafeingcrokodil.com"
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = "staging"
  }
}
