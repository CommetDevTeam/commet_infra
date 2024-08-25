# Access Identity Provider for Application
locals {
  cloudflare_sso_github_client_id     = data.google_secret_manager_secret_version.cloudflare_sso_github_client_id.secret_data
  cloudflare_sso_github_client_secret = data.google_secret_manager_secret_version.cloudflare_sso_github_client_secret.secret_data
}

resource "cloudflare_zero_trust_access_identity_provider" "github_sso" {
  zone_id = local.cloudflare_zone_id
  name    = "GitHub OAuth"
  type    = "github"
  config {
    client_id     = local.cloudflare_sso_github_client_id
    client_secret = local.cloudflare_sso_github_client_secret
  }
}

# Application for Proxmox
resource "cloudflare_zero_trust_access_application" "onp_admin_proxmox" {
  zone_id          = local.cloudflare_zone_id
  name             = "Proxmox administration"
  domain           = "proxmox.${local.root_domain}"
  type             = "self_hosted"
  session_duration = "24h"

  http_only_cookie_attribute = true
}

resource "cloudflare_zero_trust_access_policy" "onp_admin_proxmox" {
  application_id = cloudflare_zero_trust_access_application.onp_admin_proxmox.id
  zone_id        = local.cloudflare_zone_id
  name           = "Require to be in a GitHub team to access"
  precedence     = "1"
  decision       = "allow"
  include {
    github {
      name                 = local.github_org_name
      teams = ["admin-team"]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.github_sso.id
    }
  }
  include {
    email = ["kaname.imaichi@gmail.com"]
  }
}

# Application for Argocd
resource "cloudflare_zero_trust_access_application" "onp_admin_argocd" {
  zone_id          = local.cloudflare_zone_id
  name             = "Argocd administration"
  domain           = "argocd.${local.root_domain}"
  type             = "self_hosted"
  session_duration = "24h"

  http_only_cookie_attribute = true
}

resource "cloudflare_zero_trust_access_policy" "onp_admin_argocd" {
  application_id = cloudflare_zero_trust_access_application.onp_admin_argocd.id
  zone_id        = local.cloudflare_zone_id
  name           = "Require to be in a GitHub team to access"
  precedence     = "1"
  decision       = "allow"
  include {
    github {
      name                 = local.github_org_name
      teams = ["admin-team"]
      identity_provider_id = cloudflare_zero_trust_access_identity_provider.github_sso.id
    }
  }
  include {
    email = ["kaname.imaichi@gmail.com"]
  }
}