{
  description = "Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    agenix.url = "github:ryantm/agenix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:LnL7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-bundle.url = "github:homebrew/homebrew-bundle";
    homebrew-bundle.flake = false;

    homebrew-core.url = "github:homebrew/homebrew-core";
    homebrew-core.flake = false;

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    secrets.url = "git+ssh://git@github.com/andreykaipov/nix-secrets.git";
    secrets.flake = false;

    # zsh plugins
    zsh-powerlevel10k.url = "github:romkatv/powerlevel10k";
    zsh-powerlevel10k.flake = false;
    zsh-completions.url = "github:zsh-users/zsh-completions";
    zsh-completions.flake = false;
    zsh-fzf-tab.url = "github:Aloxaf/fzf-tab";
    zsh-fzf-tab.flake = false;
    zsh-fzf-tab-source.url = "github:Freed-Wu/fzf-tab-source";
    zsh-fzf-tab-source.flake = false;
    zsh-almostontop.url = "github:Valiev/almostontop";
    zsh-almostontop.flake = false;
    lscolors.url = "github:trapd00r/LS_COLORS";
    lscolors.flake = false;

    llm-agents.url = "github:numtide/llm-agents.nix";
  };
  outputs =
    inputs:
    let
      lib = import ./lib { inherit inputs; };
      hosts = import ./hosts { inherit lib; };
    in
    {
      apps = lib.forAvailableSystems lib.mkApps;
    }
    // lib.mkConfigs hosts;
}
