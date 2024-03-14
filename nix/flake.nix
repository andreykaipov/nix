{
  description = "Andrey's Home Configurations";

  inputs = {
    # https://status.nixos.org/
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    # nixpkgs-master.url = "github:nixos/nixpkgs/master";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv/latest"; # don't follow
    neovim-nightly.url = "github:neovim/neovim?dir=contrib"; #" #&rev=eb151a9730f0000ff46e0b3467e29bb9f02ae362";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    # zsh plugins
    # (some are available via nixpkgs but this way we can always keep them up to date)
    zsh-powerlevel10k.url = "github:romkatv/powerlevel10k";
    zsh-powerlevel10k.flake = false;
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-fzf-tab.url = "github:Aloxaf/fzf-tab";
    zsh-fzf-tab.flake = false;
    zsh-fzf-tab-source.url = "github:Freed-Wu/fzf-tab-source";
    zsh-fzf-tab-source.flake = false;
    zsh-fzf-zsh-plugin.url = "github:unixorn/fzf-zsh-plugin";
    zsh-fzf-zsh-plugin.flake = false;
    lscolors.url = "github:trapd00r/LS_COLORS";
    lscolors.flake = false;
    zsh-edit.url = "github:marlonrichert/zsh-edit";
    zsh-edit.flake = false;
    zsh-almostontop.url = "github:Valiev/almostontop";
    zsh-almostontop.flake = false;
    zsh-autocomplete.url = "github:marlonrichert/zsh-autocomplete";
    zsh-autocomplete.flake = false;
  };

  outputs = { self, ... }: {
    homeConfigurations =
      let
        configure = import ./home/config.nix { flake = self; };
        hosts = [
          "smart-toaster"
          "dustbox"
        ];
        inherit (builtins) map listToAttrs;
      in
      listToAttrs (map (host: { name = host; value = configure host; }) hosts);
    # zipAttrsWith (_: head) (map (host: { "${host}" = configure host; }) hosts);
  };
}
