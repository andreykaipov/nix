{ inputs
, config
, pkgs
, ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    history = rec {
      path = "${config.xdg.dataHome}/zsh/history"; # ~/.local/share/...
      share = false;
      extended = true;
      save = 100000;
      size = save;
      ignorePatterns = [ "rm *" ];
      ignoreDups = true; # makes searching history faster
      ignoreAllDups = true;
      ignoreSpace = false;
      expireDuplicatesFirst = false;
    };
    initExtraFirst = ''
      # macos upgrades might nix install: https://github.com/NixOS/nix/issues/3616
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # To customize prompt, run `p10k configure` or edit p10k.zsh.
      # The following enables instant-prompt for p10k. It should be at the top of our generated ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n] confirmations, etc.)
      # can go here too, but should be above this conditional.
      # ref: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    autosuggestion.enable = true; # via forward-word ^[f or end-of-line ^e
    enableCompletion = true; # this only enables completion for 'nix *' commands, literally only that
    completionInit = ''
      source "${inputs.zsh-completions}/zsh-completions.plugin.zsh"
      # autoload -Uz +X compinit && compinit
      # autoload -Uz +X bashcompinit && bashcompinit
      # fzf, enables it for ^r, ^s and tab completion
      source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/fzf/fzf.plugin.zsh"
      source "${inputs.zsh-fzf-tab}/fzf-tab.plugin.zsh"
      source "${inputs.zsh-fzf-tab-source}/fzf-tab-source.plugin.zsh"
      source "${inputs.zsh-autocomplete}/zsh-autocomplete.plugin.zsh" # i like it only for the auto list
      source "${inputs.zsh-almostontop}/almostontop.plugin.zsh" # this goes really great with above
      complete -o nospace -C ${pkgs.terragrunt}/bin/terragrunt terragrunt
    '';
    initExtra = ''
      source "${inputs.lscolors}/lscolors.sh"

      ### our zshrc
      ${builtins.readFile ./zshrc}

      ### p10k
      source "${inputs.zsh-powerlevel10k}/powerlevel10k.zsh-theme"
      ${builtins.readFile ./p10k.zsh}
    '';
    envExtra = ''
      export FZF_BASE=${pkgs.fzf}/share/fzf
      ${builtins.readFile ./zshenv}
    '';
    shellAliases = {
      ll = "eza --group --header --group-directories-first --long --git --all --icons --sort name";
      g = "git";
      gs = "git status";
      cat = "bat";
    };
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
      G = "| grep";
    };
  };
}
