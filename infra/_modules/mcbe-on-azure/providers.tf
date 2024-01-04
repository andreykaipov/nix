terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 4.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 1.0, < 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.0, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  client_id                  = var.az_service_principal.appId
  client_secret              = var.az_service_principal.password
  tenant_id                  = var.az_service_principal.tenantId
  subscription_id            = var.az_service_principal.subscriptionId
}

provider "cloudflare" {
  api_token = var.cf_api_token
}
