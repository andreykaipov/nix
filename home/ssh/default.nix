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
    # TODO: set symlinks back to true. with them off, it's no different than
    # just maintaing the keys manually, but it would be nice to have them on
    # since reboots break the symlink and remove the decryption key from tmp
    #
    # would be neat to wrap the hm-switch in a script that reads the decryption
    # key from 1password and then runs it when i open up wezterm, like in the
    # bootstrap.sh.mustache script then we can set symlinks = true again

    age.decrypt."ghbastion.pem.age" = {
      path = "${config.home.homeDirectory}/.config/ssh/keys/ghbastion.pem";
      mode = "600";
      symlink = false;
    };

    age.decrypt."${hostname}.pem.age" = {
      path = "${config.home.homeDirectory}/.config/ssh/keys/${hostname}.pem";
      mode = "600";
      symlink = false;
    };

    # don't use programs.ssh.enable for the same reason we don't do it for tmux
    home.packages = with pkgs; [ openssh ];
    home.file.".ssh".source = config.lib.file.mkOutOfStoreSymlink "${config.gitRoot}/home/ssh";

    # SSH doesn't really support XDG config paths, so these are workarounds
    # See https://wiki.archlinux.org/index.php/XDG_Base_Directory
    #
    # Why not just let it go to ~/.ssh/config so I don't have to do this?
    # Because I'm a stubborn little bitch.
    # programs.zsh.shellAliases = {
    # ssh = "ssh -F ~/.config/ssh/config";
    # scp = "scp -F ~/.config/ssh/config";
    # };
  };
}
