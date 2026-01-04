{
  ...
}:

let
  name = "Andrey Kaipov";
  email = "9457739+andreykaipov@users.noreply.github.com";
in
{
  programs.git = {
    enable = true;
    ignores = [ "*.swp" ];
    lfs = {
      enable = true;
    };
    settings = {
      user = {
        inherit name email;
      };
      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };
}
