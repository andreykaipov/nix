variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_size" {
  type    = string
  default = "Standard_F2"
}

variable "name" {
  type        = string
  description = <<EOF
An identifying name for this module. It can be your favorite food, or something
boring like the FQDN you'd like to use for the server. In the latter case, you
won't need to set the `cf_full_record` variable.

This variable will be prepended to all Azure resources created by this module.
EOF
}

variable "server_name" {
  type        = string
  default     = "Dedicated Server"
  description = "The server name shown in the in-game server list."
}

variable "level_name" {
  type        = string
  default     = "Bedrock level"
  description = <<EOF
The name of the world, e.g. "Bedrock level".
Change this if you want to load a different world on the server.
This variable is called `level_name` because that's what it's called in the
`server.properties` file.
EOF
}

variable "cf_full_record" {
  type        = string
  default     = ""
  description = <<EOF
The full Cloudflare DNS record, e.g. my.mc.example.com.
If empty, its value will try to be parsed from the `name` variable.
EOF
}

variable "onepassword_vault" {
  type        = string
  default     = ""
  description = "If nonempty, we'll write the secrets to this 1Password vault."
}

variable "bedrock_bridge_token" {
  type        = string
  default     = ""
  description = <<EOF
The secret token from Discord to connect to Bedrock Bridge.
See https://github.com/InnateAlpaca/BedrockBridge/.
EOF
}
