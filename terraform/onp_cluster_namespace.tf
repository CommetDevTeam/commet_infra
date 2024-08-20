resource "kubernetes_namespace" "onp_cluster_argocd" {
  metadata {
    name = "argocd"
  }
}