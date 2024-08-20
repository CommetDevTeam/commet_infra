terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    #     github = {
    #       source  = "integrations/github"
    #       version = "6.2.3"
    #     }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.73.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.73.1"
    }
  }
  backend "gcs" {
    bucket = "commet-terraform"
    prefix = "dev/k8s"
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# github actions に githubのsecretから環境変数として渡しているため指定不要。
# provider "cloudflare" {}

# ローカルで実行する場合は、terraform.tfvarsの`cloudflare-api-token`にTokenを追記する。
variable "cloudflare-api-token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare-api-token
}
# github actions に githubのsecretから環境変数として渡しているため指定不要。
# https://docs.github.com/ja/actions/security-guides/automatic-token-authentication
# provider "github" {
#   owner = local.github_org_name
# }

data "local_file" "example" {
  filename = "./kubeconfig/config"
}

# オンプレクラスタの kubeconfig.yaml は、cluster CA certificate、client certificate、client keyをそれぞれ
#  - clusters[?].cluster.certificate-authority-data に
#  - users[?].user.client-certificate-data に
#  - users[?].user.client-key-data に
# base64で保持している。

locals {
  onp_kubernetes_cluster_ca_certificate = base64decode(yamldecode(data.local_file.example.content).clusters[0].cluster.certificate-authority-data)
  onp_kubernetes_client_certificate = base64decode(yamldecode(data.local_file.example.content).users[0].user.client-certificate-data)
  onp_kubernetes_client_key = base64decode(yamldecode(data.local_file.example.content).users[0].user.client-key-data)
}

provider "kubernetes" {
  host                   = var.onp_k8s_server_url
  cluster_ca_certificate = local.onp_kubernetes_cluster_ca_certificate
  client_certificate     = local.onp_kubernetes_client_certificate
  client_key             = local.onp_kubernetes_client_key
}
provider "helm" {
  kubernetes {
    host                   = var.onp_k8s_server_url
    cluster_ca_certificate = local.onp_kubernetes_cluster_ca_certificate
    client_certificate     = local.onp_kubernetes_client_certificate
    client_key             = local.onp_kubernetes_client_key
  }
}
