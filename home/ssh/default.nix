{ config
, pkgs
, host
, lib
, ...
}:
let
  inherit (host) hostname;
in
{
  config = {
    age.decrypt."ghbastion.pem.age" = {
      path = "${config.home.homeDirectory}/.config/ssh/keys/ghbastion.pem";
      mode = "600";
    };

    age.decrypt."${hostname}.pem.age" = {
      path = "${config.home.homeDirectory}/.config/ssh/keys/${hostname}.pem";
      mode = "600";
    };

    # don't use programs.ssh.enable for the same reason we don't do it for tmux
    home = {
      packages = with pkgs; [ openssh ];
      file = {
        ".config/ssh".source = ./.;
        ".config/ssh".recursive = true;
      };
    };

    # SSH doesn't really support XDG config paths, so these are workarounds
    # See https://wiki.archlinux.org/index.php/XDG_Base_Directory
    #
    # Why not just let it go to ~/.ssh/config so I don't have to do this?
    # Because I'm a stubborn little bitch.
    programs.zsh.shellAliases = {
      ssh = "ssh -F ~/.config/ssh/config";
      scp = "scp -F ~/.config/ssh/config";
    };
  };
}
