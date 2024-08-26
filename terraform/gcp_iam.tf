resource "google_service_account" "github_actions" {
  project      = var.project_id
  account_id   = "github-actions-deployer"
  display_name = "github-actions-deployer"
}

# Add roles to the service account.
resource "google_project_iam_member" "github_actions" {
  for_each = toset(var.github_actions_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_service_account" "github_actions_builder" {
  project      = var.project_id
  account_id   = "github-actions-builder"
  display_name = "github-actions-builder"
}

# Add roles to the service account.
resource "google_project_iam_member" "github_actions_builder" {
  for_each = toset(var.github_actions_builder_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions_builder.email}"
}

resource "google_service_account" "artifact_registry_reader" {
  project      = var.project_id
  account_id   = "artifact-registry-reader"
  display_name = "artifact-registry-reader"
}

# Add roles to the service account.
resource "google_project_iam_member" "artifact_registry_reader" {
  for_each = toset(var.artifact_registry_reader)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.artifact_registry_reader.email}"
}