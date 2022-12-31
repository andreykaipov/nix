# There's no section on overlays, but it's sorta similar
#
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md
# https://nixos.wiki/wiki/Vim#Custom_setup_without_using_Home_Manager
#
# Plugins refer to the repo name only, i.e. LnL7/vim-nix is just vim-nix. Fully
# qualified repos with author names can be found at:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/vim-plugins/generated.nix

self: super: {
  neovim-unwrapped =
    super.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
      pname = oldAttrs.pname;
      version = "0.8.2";

      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v${version}";
        sha256 = "sha256-eqiH/K8w0FZNHLBBMjiTSQjNQyONqcx3X+d85gPnFJg=";
        #sha256 = "";
      };

      patches = oldAttrs.patches ++ [
        ./relative-numbers.patch
      ];
    });

  neovim =
    super.neovim.override (old: rec {
      viAlias = true;
      vimAlias = true;
    });
}
