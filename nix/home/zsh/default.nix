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
      # To customize prompt, run `p10k configure` or edit p10k.zsh.
      # The following enables instant-prompt for p10k. It should be at the top of our generated ~/.zshrc.
      # Initialization code that may require console input (password prompts, [y/n] confirmations, etc.)
      # can go here too, but should be above this conditional.
      # ref: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#instant-prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi
    '';
    enableAutosuggestions = true; # via forward-word ^[f or end-of-line ^e
    enableCompletion = true; # this only enables completion for 'nix *' commands, literally
    completionInit = ''
      source "${inputs.zsh-completions}/zsh-completions.plugin.zsh"
      autoload -Uz +X compinit && compinit
      autoload -Uz +X bashcompinit && bashcompinit
      complete -o nospace -C ${pkgs.terragrunt}/bin/terragrunt terragrunt
      # fzf, enables it for ^r and tab completion
      source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/fzf/fzf.plugin.zsh"
      source "${inputs.zsh-fzf-tab}/fzf-tab.plugin.zsh"
      source "${inputs.zsh-fzf-tab-source}/fzf-tab-source.plugin.zsh"
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
      ll = "eza --group --header --group-directories-first --long --git --all --icons";
    };
    shellGlobalAliases = {
      UUID = "$(uuidgen | tr -d \\n)";
      G = "| grep";
    };
  };

  # see LESSOPEN in zshenv
  home.file."bin/lessfilter".source = ./lessfilter;
}
# oh-my-zsh.enable = false;
# oh-my-zsh.plugins = [
#   # https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
#   "aliases"
#   "asdf"
#   "autojump"
#   # "docker" # not always available on WSL depending on if Docker Desktop is on or not
#   "fzf"
#   "gh"
#   "git"
#   "terraform"
#   "themes"
# ];
# oh-my-zsh.extraConfig = ''
#   # happens before oh-my-zsh is sourced
#
#   # specifically bracketed paste
#   # without this pasting into the terminal is super slow
#   # export DISABLE_MAGIC_FUNCTIONS=true
#
# '';
