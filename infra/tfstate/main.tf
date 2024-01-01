terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = local.secrets.setup["cloudflare_api_token"]
}

locals {
  cf_account_id = local.secrets.setup["cloudflare_account_id"]
}

variable "tf_backend_username" {}
variable "tf_backend_password" {}

resource "cloudflare_workers_kv_namespace" "tfstate" {
  account_id = local.cf_account_id
  title      = "tfstate"
}

resource "cloudflare_worker_script" "tfstate" {
  account_id = local.cf_account_id
  name       = "tfstate-handler"
  content = templatefile("index.js.tmpl", {
    kv_namespace = cloudflare_workers_kv_namespace.tfstate.title
    username     = var.tf_backend_username
    password     = var.tf_backend_password
  })

  kv_namespace_binding {
    name         = cloudflare_workers_kv_namespace.tfstate.title
    namespace_id = cloudflare_workers_kv_namespace.tfstate.id
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
