{
  inputs,
  config,
  pkgs,
  lib,
  host,
  secrets,
  ...
}:

let
  envDir = "${secrets}/env";
  hasEnvDir = builtins.pathExists envDir;

  # Discover all zshenv.*.age files in nix-secrets/env/
  secretEnvFiles =
    if hasEnvDir then
      lib.pipe (builtins.readDir envDir) [
        (lib.filterAttrs (name: _: lib.hasPrefix "zshenv." name && lib.hasSuffix ".age" name))
        (lib.mapAttrsToList (name: _: lib.removeSuffix ".age" name))
      ]
    else
      [ ];
in
{
  age.secrets = lib.listToAttrs (
    map (name: {
      inherit name;
      value = {
        file = "${envDir}/${name}.age";
        path = "${host.gitRoot}/modules/home/shell/config/${name}";
        symlink = false;
        mode = "600";
      };
    }) secretEnvFiles
  );

  home.packages = with pkgs; [
    bat
    eza
    fzf
    lesspipe
    oh-my-zsh
  ];

  xdg.configFile."zsh/config" = host.symlinkTo ./config;

  # Redirect `npm install -g` to a writable directory instead of /nix/store.
  # ~/.npm-global/bin is added to PATH via zshenv.
  xdg.configFile."npm/npmrc".text = ''
    prefix=~/.npm-global
  '';

  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "emacs";
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    history = rec {
      path = "${config.xdg.dataHome}/zsh/history";
      share = false;
      extended = true;
      save = 100000;
      size = save;
      ignorePatterns = [ "rm *" ];
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = false;
      expireDuplicatesFirst = false;
    };
    autosuggestion.enable = true;
    envExtra = ''
      export FZF_BASE=${pkgs.fzf}/share/fzf
      source "$ZDOTDIR/config/zshenv"
    ''
    + lib.concatMapStrings (name: ''
      # Source secret env: ${name}
      source "${host.gitRoot}/modules/home/shell/config/${name}"
    '') secretEnvFiles;
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # To customize prompt, run `p10k configure` or edit p10k.zsh.
        # The following enables instant-prompt for p10k. It should be at the top of our generated ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n] confirmations, etc.)
        # can go here too, but should be above this conditional.
        # ref: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      ''
        source "${inputs.lscolors}/lscolors.sh"

        ### our zshrc
        source "$ZDOTDIR/config/zshrc"

        ### p10k
        source "${inputs.zsh-powerlevel10k}/powerlevel10k.zsh-theme"
        source "$ZDOTDIR/config/p10k.zsh"
      ''
    ];
    enableCompletion = true;
    completionInit = ''
      source "${inputs.zsh-completions}/zsh-completions.plugin.zsh"
      autoload -Uz +X compinit
      autoload -Uz +X bashcompinit

      # Cache compinit — only regenerate if the dump is older than 24h.
      # After a `switch`, delete ~/.zcompdump* to force a refresh.
      _comp_dump="''${ZDOTDIR:-$HOME}/.zcompdump"
      if [[ -f "$_comp_dump" && $(date +'%j') == $(stat -f '%Sm' -t '%j' "$_comp_dump" 2>/dev/null) ]]; then
        compinit -C  # skip security check and use cache
      else
        compinit
      fi
      bashcompinit

      # fzf, enables it for ^r, ^s and tab completion
      source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/fzf/fzf.plugin.zsh"
      source "${inputs.zsh-fzf-tab}/fzf-tab.plugin.zsh"
      source "${inputs.zsh-fzf-tab-source}/fzf-tab-source.plugin.zsh"
      source "${inputs.zsh-almostontop}/almostontop.plugin.zsh"
      complete -o nospace -C ${pkgs.terragrunt}/bin/terragrunt terragrunt
    '';
    shellAliases = {
      ll = "eza --group --header --group-directories-first --long --git --all --icons --sort name";
      g = "git";
      gs = "git status";
      gd = "git diff";
      gdc = "git diff --cached";
      gdn = "git diff --name-only";
      cat = "bat";
    };
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
      G = "| grep";
    };
  };
}
