retry_max_attempts       = 3
retry_sleep_interval_sec = 10

locals {
  // e.g. /home/andrey/gh/self
  git_dir = run_cmd("--terragrunt-quiet", "sh", "-c", "git rev-parse --show-toplevel")

  project_name = reverse(split("/", local.git_dir))[0]

  tfstate_kv_path = substr(get_terragrunt_dir(), length(local.git_dir) - length(local.project_name), -1)
}

inputs = {}

remote_state {
  generate = {
    path      = "zz_generated.backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  backend = "http"
  config = {
    username       = get_env("TF_BACKEND_USERNAME")
    password       = get_env("TF_BACKEND_PASSWORD")
    address        = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    lock_address   = "https://tf.kaipov.com/${local.tfstate_kv_path}"
    unlock_address = "https://tf.kaipov.com/${local.tfstate_kv_path}"
  }
}

# declare the 1password provider without conflicts
# (https://developer.hashicorp.com/terraform/language/files/override)
generate "provider_override" {
  path      = "zz_generated.provider_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 1.0, < 2.0"
    }
  }
}
EOF
}

generate "secrets" {
  path      = "zz_generated.secrets.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
locals {
  secrets = {
    for section in data.onepassword_item.secrets.section:
    section.label => {
      for field in section.field:
      field.label => field.value
    }
    if section.label != ""
  }

  az_service_principal = jsondecode(local.secrets.setup["az_service_principal_json"])
}

data "onepassword_vault" "vault" {
  name = "github"
}

data "onepassword_item" "secrets" {
  vault = data.onepassword_vault.vault.uuid
  title = "self"
}
EOF
}
