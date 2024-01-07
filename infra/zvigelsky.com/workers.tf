variable "links" {
  type    = list(string)
  default = ["https://google.com"]
}

variable "games" {
  type        = map(number)
  default     = {}
  description = "Map of games to their probability of being selected. Must add up to 1."
  validation {
    condition     = length(keys(var.games)) == 0 || sum(values(var.games)) == 1
    error_message = "The probabilities of all games must add up to 1."
  }
}

locals {
  bindings = [
    {
      kind = "plain_text"
      name = "links"
      text = jsonencode(var.links)
    },
    {
      kind = "plain_text"
      name = "games"
      text = jsonencode(var.games)
    }
  ]

  workers = {
    root   = [cloudflare_zone.zone.zone],
    gaming = ["whatgameisallanplayingtonight.${cloudflare_zone.zone.zone}"]
  }
}

module "worker" {
  for_each   = local.workers
  source     = "./cloudflare-worker"
  account_id = local.cf_account_id
  zone       = cloudflare_zone.zone
  name       = each.key
  domains    = each.value
  script     = file("js/${each.key}.js")
  bindings   = local.bindings
}
