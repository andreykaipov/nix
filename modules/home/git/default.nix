{
  pkgs,
  host,
  ...
}:

let
  name = "Andrey Kaipov";
  email = "9457739+andreykaipov@users.noreply.github.com";
in
{
  home.packages = with pkgs; [
    git
    git-filter-repo
    gh
    lazygit
  ];

  programs.git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    settings = {
      user = {
        inherit name email;
        signingkey = "${host.homeDirectory}/.ssh/keys/${host.hostname}.pem.pub";
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
