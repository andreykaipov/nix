include "root" {
  path = find_in_parent_folders()
}

locals {
  links = [
    "https://i.imgur.com/uzlddLE.gif",
    "https://i.imgur.com/1ANnqYg.png",
    "https://dotabuff.com/players/122152013",
    "https://www.linkedin.com/in/allan-zvigelsky",
    "https://www.youtube.com/watch?v=tL4Bc7GH3RM&t=110s",
    "https://youtu.be/Ty-uONDAen0?si=vVnGBQJR10i0qb3P&t=1052",
  ]

  // add up to 1
  games = {
    "Helldivers 2"    = 0.2
    "Minecraft"       = 0.2
    "Anime Night"     = 0.1
    "Amogus"          = 0.1
    "Genshin Impact"  = 0.1
    "Project Zomboid" = 0.1
    "Discord Chat"    = 0.1
    "Civ 6"           = 0.1
  }
}

inputs = {
  links = local.links
  games = local.games
}
