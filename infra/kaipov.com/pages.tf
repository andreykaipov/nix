locals {
  custom_domain = cloudflare_zone.kaipov.zone
  project_name  = replace(lower(local.custom_domain), "/[^a-z0-9-]+/", "-")
}

resource "cloudflare_record" "pages" {
  zone_id = cloudflare_zone.kaipov.id
  name    = "@"
  type    = "CNAME"
  value   = cloudflare_pages_project.website.subdomain
  proxied = true
  ttl     = 1
}

resource "cloudflare_pages_domain" "domain" {
  account_id   = local.cf_account_id
  project_name = cloudflare_pages_project.website.name
  domain       = local.custom_domain
}

resource "cloudflare_pages_project" "website" {
  account_id        = local.cf_account_id
  name              = local.project_name
  production_branch = "main"

  source {
    type = "github"
    config {
      owner                         = "andreykaipov"
      repo_name                     = "self"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
      preview_deployment_setting    = "all"
    }
  }

  build_config {
    build_command   = "hugo"
    destination_dir = "public"
    root_dir        = "website"
    build_caching   = true
  }
}
