self: super: {
  tmux = super.tmux.overrideAttrs (old: rec {
    pname = old.pname;
    version = "ee3f1d25d568a425420cf14ccba6a1b2a012f7dd";

    src = super.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = version;
      sha256 = "sha256-LLQ2/SYv/4oQpygiA9+HFjLRODi7Z4EWnkNk9CvMRro=";
    };

    patches = [
      ./version-custom.patch
      ./pane-border-indent.patch
    ];
  });
}
