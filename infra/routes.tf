
locals {
  subdomain_routes = merge(
    local.resume_routes,
    {
      # www redirect with workers to conserve page rules :)
      "www" = { to = "https://${cloudflare_zone.kaipov.zone}", preserve_path = true }
    }
  )

  path_routes = merge(local.resume_routes, {})

  # For the neat links in our resume, used in both subdomain and path routes
  # since I can't decide which one I like yet.
  resume_routes = {
    "goobs"     = { to = "https://github.com/andreykaipov/goobs" }
    "funcopgen" = { to = "https://github.com/andreykaipov/funcopgen" }
  }
}

###

resource "cloudflare_worker_script" "subdomain_routes" {
  for_each = local.subdomain_routes
  name     = "${each.key}-301"
  content = templatefile("js/redirect-301.js.tmpl", {
    base          = each.value.to
    preserve_path = try(each.value.preserve_path, false)
  })
}

resource "cloudflare_worker_route" "subdomain_routes" {
  for_each    = local.subdomain_routes
  zone_id     = cloudflare_zone.kaipov.id
  pattern     = "${each.key}.${cloudflare_zone.kaipov.zone}/*"
  script_name = cloudflare_worker_script.subdomain_routes[each.key].name
}

resource "cloudflare_record" "subdomain_routes" {
  for_each = local.subdomain_routes
  zone_id  = cloudflare_zone.kaipov.id
  name     = each.key
  type     = "CNAME"
  value    = cloudflare_zone.kaipov.zone
  proxied  = true
  ttl      = 1
}

###

resource "cloudflare_worker_script" "path_routes" {
  for_each = local.path_routes
  name     = "path-${each.key}-301"
  content = templatefile("js/redirect-301.js.tmpl", {
    base          = each.value.to
    preserve_path = try(each.value.preserve_path, false)
  })
}

resource "cloudflare_worker_route" "path_routes" {
  for_each    = local.path_routes
  zone_id     = cloudflare_zone.kaipov.id
  pattern     = "${cloudflare_zone.kaipov.zone}/${each.key}*"
  script_name = cloudflare_worker_script.path_routes[each.key].name
}
