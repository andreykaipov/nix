{ config
, host
, lib
, ...
}:
{
  home = {
    sessionVariables = {
      NIX_REPO_GIT_ROOT = config.gitRoot;
    };

    file."bin".source = config.lib.file.mkOutOfStoreSymlink "${config.gitRoot}/home/scripts/bin";

    # to keep the user path intact when running the activation scripts
    emptyActivationPath = false;
    activation = lib.my.activationScripts (map toString [
      ''
        mkdir -p ~/.{cache,config,local,run}
        echo 1
        echo '${config.root}'
        echo '${host.hostname}'
      ''
      # echo '${lib.my.gitRoot}'
      # echo hello??
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
