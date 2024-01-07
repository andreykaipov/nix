include "root" {
  path = find_in_parent_folders()
}

inputs = {
  servers = [
    {
      name        = "winrar.mc.kaipov.com"
      server_name = "WinRAR 3.60 beta 5 rucrk"
      level_name  = "world"
    },
    {
      name        = "dota2.mc.zvigelsky.com"
      server_name = "Passolo v5.0.007RetailCrk"
      level_name  = "world2"
    },
    {
      name        = "island.mc.volianski.com"
      server_name = "Magic DVD Ripper 4.3.1kg"
      level_name  = "island-mp"
    },
  ]
}
