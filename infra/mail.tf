locals {
  # TODO consider just using email forwarding with Google. see
  # https://support.google.com/domains/answer/3251241 and
  # https://support.google.com/domains/answer/9428703
  zoho_records = {
    verification = {
      type  = "TXT"
      value = "zoho-verification=zb14729599.zmverify.zoho.com"
    }
    mx1 = {
      type     = "MX"
      value    = "mx.zoho.com"
      priority = 10
    }
    mx2 = {
      type     = "MX"
      value    = "mx2.zoho.com"
      priority = 20
    }
    mx3 = {
      type     = "MX"
      value    = "mx3.zoho.com"
      priority = 50
    }
    spf = {
      type  = "TXT"
      value = "v=spf1 mx include:zoho.com ~all"
    }
    dkim = {
      name  = "zoho._domainkey"
      type  = "TXT"
      value = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC0Jm9koh3FQdqtxIscnlwtEdJlS+HTZyk398URohMR02qUqwgWm6dbNN0T+fl4VgY2zLD97k9FemJ4zfv5/YZnkHcUAlWw25rVIQSB1nMbqCAEGtxh9LG8XuLWmFYqoUVLYuhkmb3WKq0nzDHSGJVv1aacJNp4wna9NLX0P++W0wIDAQAB"
    }
  }
}

resource "cloudflare_record" "zoho" {
  for_each = local.zoho_records

  zone_id  = cloudflare_zone.kaipov.id
  name     = try(each.value.name, local.zone)
  type     = each.value.type
  value    = each.value.value
  priority = try(each.value.priority, null)
  ttl      = 1
  proxied  = false
}
