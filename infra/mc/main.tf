locals {
  servers = [
    {
      name        = "island.mc.volianski.com"
      server_name = "Magic DVD Ripper 4.3.1kg"
      level_name  = "island-mp"
    },
    {
      name        = "winrar.mc.volianski.com"
      server_name = "WinRAR 3.60 beta 5 rucrk"
      level_name  = "world"
    },
    {
      name        = "shadow.mc.volianski.com"
      server_name = "Passolo v5.0.007RetailCrk"
      level_name  = "world2"
    }
  ]

  servers_yml = yamlencode({
    check_interval         = "3m"
    deallocation_threshold = 5
    check_timeout          = "10s"
    servers = values({
      for server in local.servers :
      server.name => { host = server.name }
    })
  })
}

module "mcserver" {
  for_each             = { for _, v in local.servers : v.name => v }
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
  sha      = "sha256:101c588c6bd815ba4055a4fde76411e2be9f2578bd8db4fc09bdea5ff1147cb4"

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
