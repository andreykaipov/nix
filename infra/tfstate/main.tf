locals {
  cf_account_id = local.secrets.setup["cloudflare_account_id"]
}

resource "random_string" "creds" {
  count  = 2
  length = 64
}

resource "cloudflare_workers_kv_namespace" "tfstate" {
  account_id = local.cf_account_id
  title      = "tfstate"
}

resource "cloudflare_worker_script" "tfstate" {
  account_id = local.cf_account_id
  name       = "tfstate-handler"
  content    = file("index.js")
  module     = true
  kv_namespace_binding {
    name         = cloudflare_workers_kv_namespace.tfstate.title
    namespace_id = cloudflare_workers_kv_namespace.tfstate.id
  }
  secret_text_binding {
    name = "username"
    text = random_string.creds[0].result
  }
  secret_text_binding {
    name = "password"
    text = random_string.creds[1].result
  }
}

data "cloudflare_zone" "kaipov" {
  name = "kaipov.com"
}

resource "cloudflare_worker_route" "terraform_route" {
  zone_id     = data.cloudflare_zone.kaipov.zone_id
  pattern     = "tf.${data.cloudflare_zone.kaipov.name}/*"
  script_name = cloudflare_worker_script.tfstate.name
}
