self: super: {
  tmux = super.tmux.overrideAttrs (old: rec {
    pname = old.pname;
    version = "b54e1fc4f73b34f3f9c671289fef8cbbc7771d9c";

    src = super.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = version;
      sha256 = "sha256-S+BGRaEceN2rG/RNcVTJjwvzPa1JSMtDn1hu8F0Gkr8=";
    };

    patches = [
      ./version-custom.patch
      ./pane-border-indent.patch
    ];
  });
}
