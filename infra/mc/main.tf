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
