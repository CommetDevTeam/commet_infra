resource "kubernetes_secret" "onp_argocd_github_oauth_app_secret" {
  depends_on = [kubernetes_namespace.onp_cluster_argocd]
  metadata {
    name      = "argocd-github-oauth-app-secret"
    namespace = "argocd"
    labels = {
      # これが必要っぽい
      # https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#alternative
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    ARGOCD_GITHUB_OAUTH_APP_SECRET = data.google_secret_manager_secret_version.argocd_github_oauth_app_secret.secret_data
  }
  type = "Opaque"
}

resource "random_password" "server_list_mariadb_root_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "server_list_mariadb_server_list_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "server_list_mariadb_password" {
  depends_on = [kubernetes_namespace.onp_cluster_server-list]

  metadata {
    name      = "mariadb"
    namespace = "server-list"
  }

  data = {
    "root-password"        = random_password.server_list_mariadb_root_password.result
    "server-list-password" = random_password.server_list_mariadb_server_list_password.result
    "database-url"         = "jdbc:mysql://192.168.0.11:31278"
  }
  type = "Opaque"
}

resource "kubernetes_secret" "image_pull_secrets" {
  metadata {
    name      = "server-list-image-pull-secrets"
    namespace = "server-list"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      docker-server   = "https://gcr.io"
      docker-username = "_json_key"
      docker-password = data.google_secret_manager_secret_version.artifact_registry_reader_account_key.secret_data
      docker-email    = google_service_account.artifact_registry_reader.email
    })
  }
}