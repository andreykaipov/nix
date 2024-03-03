{ inputs
, config
, lib
, pkgs
, ...
}:
{
  # config = lib.mkIf config.programs.zsh.enable { }

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''
      echo "completion enabled"
    '';
    enableAutosuggestions = true; # via forward-word ^[f or end-of-line ^e
    autocd = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    history = rec {
      path = "${config.xdg.dataHome}/zsh/history"; # ~/.local/share/...
      share = true;
      extended = true;
      save = 100000;
      size = save;
      ignorePatterns = [ "rm *" ];
      ignoreDups = true;
      ignoreAllDups = false;
      ignoreSpace = false;
      expireDuplicatesFirst = false;
    };
    syntaxHighlighting.enable = true;
    oh-my-zsh.enable = true;
    oh-my-zsh.plugins = [
      # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
      "aliases"
      "asdf"
      "autojump"
      "docker"
      "fzf"
      "gh"
      "git"
      "terraform"
      "themes"
    ];
    oh-my-zsh.extraConfig = ''
      # happens before oh-my-zsh is sourced
      # appends to fpath
      # sourcing these completions has to be before oh-my-zsh is sourced
      # ref: https://github.com/zsh-users/zsh-completions/issues/603
      source "${inputs.zsh-completions}/zsh-completions.plugin.zsh"
    '';
    envExtra = ''
      export FZF_BASE=${pkgs.fzf}/share/fzf
      ${builtins.readFile ./zshenv}
    '';
    initExtraFirst = ''
      # To customize prompt, run `p10k configure` or edit p10k.zsh.
      # The following enables instant-prompt for p10k. It should be at the top of our generated ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n] confirmations, etc.)
      # can go here too, but should be above this conditional.
      # ref: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    initExtraBeforeCompInit = ''
    '';
    initExtra = ''
      # autoload -U +X bashcompinit && bashcompinit
      complete -o nospace -C ${pkgs.terragrunt}/bin/terragrunt terragrunt

      ### p10k
      ${builtins.readFile ./p10k.zsh}
      ### sources
      source "${inputs.zsh-powerlevel10k}/powerlevel10k.zsh-theme"
      source "${inputs.zsh-fzf-tab}/fzf-tab.plugin.zsh"
      source "${inputs.zsh-fzf-tab-source}/fzf-tab-source.plugin.zsh"
      ### our zshrc
      ${builtins.readFile ./zshrc}
    '';
  };
}
