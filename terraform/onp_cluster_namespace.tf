resource "kubernetes_namespace" "onp_cluster_argocd" {
  metadata {
    name = "argocd"
  }
}
resource "kubernetes_namespace" "onp_cluster_cloudflared-tunnel-exits" {
  metadata {
    name = "cloudflared-tunnel-exits"
  }
}