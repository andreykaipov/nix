{ pkgs
, ...
}:
{
  # don't use programs.ssh.enable for the same reason we don't do it for tmux
  home.packages = with pkgs; [ openssh ];
  home.file.".config/ssh".source = ./.;
  home.file.".config/ssh".recursive = true;

  # TODO: figure out a way to use private keys here
  # i have all the public keys
  # maybe read from personal 1password?

  # SSH doesn't really support XDG config paths, so these are workarounds
  # See https://wiki.archlinux.org/index.php/XDG_Base_Directory
  #
  # Why not just let it go to ~/.ssh/config? Because I'm a stubborn little bitch.
  programs.zsh.shellAliases = {
    ssh = "ssh -F ~/.config/ssh/config";
    scp = "scp -F ~/.config/ssh/config";
  };
}
