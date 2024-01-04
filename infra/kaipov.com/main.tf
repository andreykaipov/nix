locals {
  cf_account_id = local.secrets.setup["cloudflare_account_id"]
}

resource "cloudflare_zone" "kaipov" {
  account_id = local.cf_account_id
  zone       = "kaipov.com"
  plan       = "free"
  type       = "full"
  paused     = false
  jump_start = false
}

resource "cloudflare_zone_settings_override" "kaipov" {
  zone_id = cloudflare_zone.kaipov.id
  settings {
    # SSL/TLS
    ssl                      = "full"
    always_use_https         = "on"
    min_tls_version          = "1.0"
    opportunistic_encryption = "on"
    tls_1_3                  = "zrt" # zero rtt below
    automatic_https_rewrites = "on"

    # Other security things
    challenge_ttl  = 1800
    security_level = "high"
    privacy_pass   = "on"

    # Speed
    minify {
      css  = "on"
      js   = "on"
      html = "on"
    }
    brotli = "on"

    # Caching
    cache_level       = "aggressive"
    browser_cache_ttl = 0
    always_online     = "off"

    # Network
    http3               = "on"
    zero_rtt            = "on"
    websockets          = "on"
    opportunistic_onion = "on"
    ip_geolocation      = "on"

    # Scrape shield
    email_obfuscation   = "on"
    server_side_exclude = "on"
  }
}

# Gonna try out Vercel instead of Cloudflare pages

/*
resource "cloudflare_record" "pages" {
  zone_id = cloudflare_zone.kaipov.id
  name    = cloudflare_zone.kaipov.zone
  type    = "CNAME"
  value   = "cname.vercel-dns.com"
  proxied = false # Vercel doesn't want us to proxy
  ttl     = 1
}
*/

resource "cloudflare_record" "pages" {
  zone_id = cloudflare_zone.kaipov.id
  name    = cloudflare_zone.kaipov.zone
  type    = "CNAME"
  value   = "kaipov.pages.dev"
  proxied = true
  ttl     = 1
}
