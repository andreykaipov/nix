locals {
  cf_full_record = var.cf_full_record == "" ? var.name : var.cf_full_record
  cf_vars        = regex("(?P<name>.+)[.](?P<zone>.+[.].+)", local.cf_full_record)
  cf_record      = local.cf_vars.name
  cf_zone        = local.cf_vars.zone
}

data "cloudflare_zone" "zone" {
  name = local.cf_zone
}

resource "cloudflare_record" "record" {
  zone_id = data.cloudflare_zone.zone.id
  type    = "A"
  name    = local.cf_record
  value   = azurerm_public_ip.public_ip.ip_address
  proxied = false
}

