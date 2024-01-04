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
  client_id                  = var.az_service_principal.appId
  client_secret              = var.az_service_principal.password
  tenant_id                  = var.az_service_principal.tenantId
  subscription_id            = var.az_service_principal.subscriptionId
}

variable "az_service_principal" {
  type = object({
    appId          = string
    password       = string
    tenantId       = string
    subscriptionId = string
  })
}
