retry_max_attempts       = 3
retry_sleep_interval_sec = 10

locals {
  // /home/andrey/gh/self
  root = get_repo_root()

  // self
  project_name = basename(local.root)

  // self/infra/project
  tfstate_path = "${local.project_name}/${get_path_from_repo_root()}"

  self_secrets_val = get_env("self_secrets")
  self_secrets = try(
    jsondecode(local.self_secrets_val),
    run_cmd("sh", "-c", <<EOF
      echo "There was an issue parsing self_secrets:"
      echo '${local.self_secrets_val}'
    EOF
    )
  )

  providers = read_terragrunt_config("providers.hcl").locals.providers
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
    if_exists = "overwrite"
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

// pass secrets to our terragrunt modules
generate "secrets" {
  path      = "zz_generated.secrets.tf"
  if_exists = "overwrite"
  contents  = <<EOF
variable "self_secrets" {
  type = string
}

locals {
  secrets = jsondecode(var.self_secrets)
}
EOF
}

# declare providers based on contents of providers.hcl in child modules.
# in case our terragrunt module declares their own providers, we use the
# override directive to avoid conflicts:
# https://developer.hashicorp.com/terraform/language/files/override
generate "provider_override" {
  path      = "zz_generated.provider_override.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    %{~if contains(local.providers, "azure")~}
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
    %{~endif~}
    %{~if contains(local.providers, "cloudflare")~}
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.0, < 5.0"
    }
    %{~endif~}
    %{~if contains(local.providers, "onepassword")~}
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 1.0, < 2.0"
    }
    %{~endif~}
  }
}

%{~if contains(local.providers, "azure")}
provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id                  = local.secrets.setup.az_service_principal.appId
  client_secret              = local.secrets.setup.az_service_principal.password
  tenant_id                  = local.secrets.setup.az_service_principal.tenantId
  subscription_id            = local.secrets.setup.az_service_principal.subscriptionId
}
%{~endif}

%{~if contains(local.providers, "cloudflare")}
provider "cloudflare" {
  api_token = local.secrets.setup.cloudflare_api_token
}
%{~endif}

%{~if contains(local.providers, "onepassword")}
provider "onepassword" {
  // set via OP_SERVICE_ACCOUNT_TOKEN env var
  // it's how we got all the other secrets
}
%{~endif}

EOF
}
