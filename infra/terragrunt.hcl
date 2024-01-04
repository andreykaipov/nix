retry_max_attempts       = 3
retry_sleep_interval_sec = 10

locals {
  // /home/andrey/gh/self
  root = get_repo_root()

  // self
  project_name = basename(local.root)

  // self/infra/project
  tfstate_path = "${local.project_name}/${get_path_from_repo_root()}"

  self_secrets = jsondecode(get_env("self_secrets"))
}

inputs = {
  self_secrets = local.self_secrets
}

terraform {
  source = "${get_repo_root()}/infra/_modules//"
}

remote_state {
  generate = {
    path      = "zz_generated.backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  backend = "http"
  config = {
    username       = local.self_secrets.setup.tf_backend_username
    password       = local.self_secrets.setup.tf_backend_password
    address        = "https://tf.kaipov.com/${local.tfstate_path}"
    lock_address   = "https://tf.kaipov.com/${local.tfstate_path}"
    unlock_address = "https://tf.kaipov.com/${local.tfstate_path}"
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
variable "self_secrets" {
  type = string
}

locals {
  secrets = jsondecode(var.self_secrets)
}
EOF
}
