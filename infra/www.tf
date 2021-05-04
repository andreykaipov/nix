# set up a www redirect with workers to conserve page rules

resource "cloudflare_worker_route" "www" {
  zone_id     = cloudflare_zone.kaipov.id
  pattern     = "www.${cloudflare_zone.kaipov.zone}/*"
  script_name = "www-redirect"
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.kaipov.id
  name    = "www"
  type    = "CNAME"
  value   = cloudflare_zone.kaipov.zone
  proxied = true
  ttl     = 1
}

# TODO move script here
