resource "google_secret_manager_secret" "cloudflare_sso_github_client_secret" {
  project   = var.project_id
  secret_id = "cloudflare_sso_github_client_secret"

  replication {
    automatic = true
  }
}
data "google_secret_manager_secret_version" "cloudflare_sso_github_client_secret" {
  secret  = google_secret_manager_secret.cloudflare_sso_github_client_secret.id
  version = "latest"
}

resource "google_secret_manager_secret" "argocd_github_oauth_app_secret" {
  project   = var.project_id
  secret_id = "argocd_github_oauth_app_secret"

  replication {
    automatic = true
  }
}
data "google_secret_manager_secret_version" "argocd_github_oauth_app_secret" {
  secret  = google_secret_manager_secret.argocd_github_oauth_app_secret.id
  version = "latest"
}

resource "google_secret_manager_secret" "server_list_github_token" {
  project   = var.project_id
  secret_id = "server_list_github_token"

  replication {
    automatic = true
  }
}
data "google_secret_manager_secret_version" "server_list_github_token" {
  secret  = google_secret_manager_secret.server_list_github_token.id
  version = "latest"
}

resource "google_secret_manager_secret" "artifact_registry_reader_account_key" {
  project   = var.project_id
  secret_id = "artifact_registry_reader_account_key"

  replication {
    automatic = true
  }
}
data "google_secret_manager_secret_version" "artifact_registry_reader_account_key" {
  secret  = google_secret_manager_secret.artifact_registry_reader_account_key.id
  version = "latest"
}