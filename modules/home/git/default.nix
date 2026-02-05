{
  pkgs,
  lib,
  host,
  ...
}:

let
  name = "Andrey Kaipov";
  email = "9457739+andreykaipov@users.noreply.github.com";
in
{
  home.packages = with pkgs; [
    git-filter-repo
    gh
    lazygit
  ];

  # Set per-repo hooksPath for the nix repo so our pre-commit hook
  # encrypts zshenv.work to nix-secrets on commit.
  home.activation.setNixRepoHooksPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "${host.gitRoot}/.git" ]; then
      ${pkgs.git}/bin/git -C "${host.gitRoot}" config core.hooksPath "${host.gitRoot}/modules/home/git/hooks"
    fi
  '';

  programs.git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    settings = {
      user = {
        inherit name email;
        signingkey = "${host.homeDirectory}/.ssh/${host.hostname}.pem.pub";
      };
      gpg.format = "ssh";
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
      credential.helper = "cache --timeout=10000";
      "diff \"plist\"".textconv = "plutil -convert xml1 -o -";
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };
}
