terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id                  = local.az_service_principal.appId
  client_secret              = local.az_service_principal.password
  tenant_id                  = local.az_service_principal.tenant
  subscription_id            = local.az_service_principal.subscriptionId
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    name = var.name
    kind = "chatbot"
  }
}

resource "azurerm_container_app_environment" "env" {
  name                = "${var.name}-env"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_container_app" "app" {
  name                         = var.name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  dynamic "secret" {
    for_each = [for k, v in var.env : substr(v, length("secret://"), -1) if startswith(v, "secret://")]
    content {
      name  = replace(secret.value, "_", "-")
      value = local.secrets[var.name][secret.value]
    }
  }

  template {
    max_replicas = 1
    min_replicas = 1

    volume {
      name         = "shared"
      storage_type = "EmptyDir"
    }

    init_container {
      name   = "copy-files"
      image  = "alpine:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      command = [
        "/bin/sh",
        "-c",
        join("\n", [
          for k, v in var.files :
          "cat >/shared/${k} <<'LOL'\n${v}\nLOL\n"
        ])
      ]

      volume_mounts {
        name = "shared"
        path = "/shared"
      }
    }

    container {
      name   = var.name
      image  = "${var.image}${var.sha == "" ? ":latest" : "@${var.sha}"}"
      cpu    = 0.25
      memory = "0.5Gi"
      # command = ["sh", "-c", "tail -f /dev/null"]
      args = ["discord"]

      dynamic "env" {
        for_each = var.env
        content {
          name        = env.key
          secret_name = startswith(env.value, "secret://") ? replace(substr(env.value, length("secret://"), -1), "_", "-") : null
          value       = startswith(env.value, "secret://") ? null : env.value
        }
      }

      volume_mounts {
        name = "shared"
        path = "/shared"
      }
    }
  }
}
