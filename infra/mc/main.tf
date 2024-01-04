module "volianski" {
  source               = "./mcbe-on-azure"
  name                 = "mc.volianski.com"
  server_name          = "Magic DVD Ripper 4.3.1kg"
  world_name           = "island-mp"
  onepassword_vault    = "github"
  az_service_principal = local.secrets.setup.az_service_principal
  cf_api_token         = local.secrets.setup.cloudflare_api_token
  bedrock_bridge_token = local.secrets.minecraft.bedrock_bridge_token_allan_server
}

locals {
  servers = {
    check_interval         = "3m"
    deallocation_threshold = 5
    servers = [
      {
        host    = "mc.volianski.com"
        timeout = "10s"
      },
    ]
  }
}

module "mcmanager" {
  source = "./azure-container-app"

  name     = "mcmanager"
  location = "eastus"
  image    = "ghcr.io/andreykaipov/discord-bots/go/mcmanager"
  sha      = "sha256:d5e86bd4c35043789aa852175d46a5a0819cebff1c0dd22e9462f3a63d650356"

  secrets = {
    discord_token      = local.secrets.minecraft.discord_token
    az_client_id       = local.secrets.setup.az_service_principal.appId
    az_client_secret   = local.secrets.setup.az_service_principal.password
    az_subscription_id = local.secrets.setup.az_service_principal.subscriptionId
    az_tenant_id       = local.secrets.setup.az_service_principal.tenantId
  }

  env = {
    AZURE_CLIENT_ID       = "secret://az_client_id"
    AZURE_CLIENT_SECRET   = "secret://az_client_secret"
    AZURE_TENANT_ID       = "secret://az_tenant_id"
    AZURE_SUBSCRIPTION_ID = "secret://az_subscription_id"
    DISCORD_TOKEN         = "secret://discord_token",
    MGMT_CHANNEL          = "1192498155200192562",
    SERVERS_FILE          = "/shared/servers.yml",
  }

  files = {
    "servers.yml" = yamlencode(local.servers)
  }

  az_service_principal = local.secrets.setup.az_service_principal
}
