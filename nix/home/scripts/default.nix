{ lib
, ...
}:
{
  home = {
    emptyActivationPath = false;

    # https://ryantm.github.io/nixpkgs/builders/trivial-builders/#trivial-builder-writeText
    file."bin/example".text = ''but not executable'';

    activation = lib.my.activationScripts (map toString [
      ''
        mkdir -p ~/.{cache,config,local,run}
      ''
      ''
        # echo "My path is: $PATH"
        echo hello??
      ''
      # ''
      #   if ! grep -q discord /etc/group; then
      #     echo "Discord group does not exist. Creating it..."
      #     sudo groupadd discord
      #   fi
      #   if ! groups ${user} | grep -qw discord; then
      #     echo "Adding ${user} to discord group..."
      #     sudo usermod -a -G discord ${user}
      #   fi
      # ''
      #./scripts/ssh-generate-authorized-keys
      #./scripts/nvim-ensure-plugins
      #./scripts/tmux-ensure-plugins
    ]);
  };
}
