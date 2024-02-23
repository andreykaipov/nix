variable "servers" {
  type = list(object({
    name        = string
    server_name = string
    level_name  = string
  }))
}

locals {
  servers_yml = yamlencode({
    check_interval         = "1m"
    deallocation_threshold = 10
    check_timeout          = "10s"
    servers = [
      for server in var.servers : {
        host = server.name
      }
    ]
  })
}

module "mcserver" {
  for_each             = { for _, v in var.servers : v.name => v }
  source               = "./mcbe-on-azure"
  name                 = each.value.name
  server_name          = each.value.server_name
  level_name           = each.value.level_name
  onepassword_vault    = "github"
  bedrock_bridge_token = local.secrets.minecraft.bedrock_bridge_token_allan_server
}

module "mcmanager" {
  source = "./azure-container-app"

  name     = "mcmanager"
  location = "eastus"
  image    = "ghcr.io/andreykaipov/discord-bots/go/mcmanager"
  sha      = "sha256:64c13a5c3615ebb687a289ff64b792933b9fc2a889619671127df2ef8277eacb"

  env = {
    AZURE_CLIENT_ID       = "secret://${local.secrets.setup.az_service_principal.appId}"
    AZURE_CLIENT_SECRET   = "secret://${local.secrets.setup.az_service_principal.password}"
    AZURE_TENANT_ID       = "secret://${local.secrets.setup.az_service_principal.tenantId}"
    AZURE_SUBSCRIPTION_ID = "secret://${local.secrets.setup.az_service_principal.subscriptionId}"
    DISCORD_TOKEN         = "secret://${local.secrets.minecraft.discord_token}"
    MGMT_CHANNEL          = "1192498155200192562",
    SERVERS_FILE          = "/shared/servers.yml",
  }

  files = {
    "servers.yml" = local.servers_yml
  }
}
