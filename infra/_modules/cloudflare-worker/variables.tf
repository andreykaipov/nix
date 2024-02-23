/*
variable "account_id" {
  type        = string
  description = <<EOF
The Cloudflare account ID to use. If not provided, the var.account_name will be
used to look up the account ID.
EOF
}

variable "account_name" {
  type        = string
  description = "The Cloudflare account name to use to look up the account ID."
}

variable "zone" {
  type = object({
    id   = string
    zone = string
  })
  description = <<EOF
An object containing the zone ID and zone name for the Cloudflare zone to use.
You can pass the cloudflare_zone resource or data.cloudflare_zone data source to
this variable directly.
EOF
}

variable "name" {
  type        = string
  description = "An identifying name for the worker script."
}

variable "bindings" {
  type = list(object({
    kv_namespace_binding = optional(object({
      name         = string
      namespace_id = string
    }))
    plain_text_binding = optional(object({
      name = string
      text = string
    }))
    secret_text_binding = optional(object({
      name = string
      text = string
    }))
    webassembly_binding = optional(object({
      name   = string
      module = string
    }))
    service_binding = optional(object({
      name        = string
      service     = string
      environment = string
    }))
    r2_bucket_binding = optional(object({
      name        = string
      bucket_name = string
    }))
    analytics_engine_binding = optional(object({
      name    = string
      dataset = string
    }))
  }))
}

variable "script" {
  type        = string
  description = "The local path to the worker script."
}

variable "module" {
  type        = bool
  default     = true
  description = "Whether to upload the script as an ES6 module."
}

variable "routes" {
  type        = set(string)
  default     = []
  description = <<EOF
A set of route patterns to bind to the worker script.
https://developers.cloudflare.com/workers/configuration/routing/
EOF
}

variable "domains" {
  type        = set(string)
  default     = []
  description = <<EOF
A set of custom domains to bind to the worker script.
https://developers.cloudflare.com/workers/configuration/routing/
EOF
}
*/
