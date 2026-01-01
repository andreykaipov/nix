{ config, pkgs, lib, ... }:

let name = "Andrey Kaipov";
    user = "andrey";
    email = "9457739+andreykaipov@users.noreply.github.com"; in
{
  # let home-manager install and manage itself
  home-manager.enable = true;

  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    cdpath = [ "~/Projects" ];
    plugins = [
      {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
          name = "powerlevel10k-config";
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
      }
    ];
    initContent = lib.mkBefore ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      # Define variables for directories
      export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
      export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
      export PATH=$HOME/.local/share/bin:$PATH

      # Remove history data we don't want to see
      export HISTIGNORE="pwd:ls:cd"

      # Ripgrep alias
      alias search=rg -p --glob '!node_modules/*'  $@

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # pnpm is a javascript package manager
      alias pn=pnpm
      alias px=pnpx

      # Use difftastic, syntax-aware diffing
      alias diff=difft

      # Always color ls and group directories
      alias ls='ls --color=auto'

      alias ll='ls -alh'
      alias vi=nvim
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "vim";
        autocrlf = "input";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  
  ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
    matchBlocks = {
      "*" = {
        # Set the default values we want to keep
        sendEnv = [ "LANG" "LC_*" ];
        hashKnownHosts = true;
      };
      "github.com" = {
        identitiesOnly = true;
        identityFile = [
          (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
            "/home/${user}/.ssh/id_github"
          )
          (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
            "/Users/${user}/.ssh/id_github"
          )
        ];
      };
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      # vim-tmux-navigator
      # sensible
      yank
      # prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
           set -g @tmux_power_theme 'gold'
        '';
      }
      # {
      #   plugin = resurrect; # Used by tmux-continuum

      #   # Use XDG data directory
      #   # https://github.com/tmux-plugins/tmux-resurrect/issues/348
      #   extraConfig = ''
      #     set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
      #     set -g @resurrect-capture-pane-contents 'on'
      #     set -g @resurrect-pane-contents-area 'visible'
      #   '';
      # }
      # {
      #   plugin = continuum;
      #   extraConfig = ''
      #     set -g @continuum-restore 'on'
      #     set -g @continuum-save-interval '5' # minutes
      #   '';
      # }
    ];
    terminal = "xterm-256color";
    # # prefix = "'M-\\'";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      unbind-key -a
      source ~/.config/tmux/0-default.conf

      bind-key    -T copy-mode    C-Space              send-keys -X begin-selection
      bind-key    -T copy-mode    C-a                  send-keys -X start-of-line
      bind-key    -T copy-mode    C-b                  send-keys -X cursor-left
      bind-key    -T copy-mode    C-c                  send-keys -X cancel
      bind-key    -T copy-mode    C-e                  send-keys -X end-of-line
      bind-key    -T copy-mode    C-f                  send-keys -X cursor-right
      bind-key    -T copy-mode    C-g                  send-keys -X clear-selection
      bind-key    -T copy-mode    C-k                  send-keys -X copy-end-of-line
      bind-key    -T copy-mode    C-n                  send-keys -X cursor-down
      bind-key    -T copy-mode    C-p                  send-keys -X cursor-up
      bind-key    -T copy-mode    C-r                  command-prompt -i -I "#{pane_search_string}" -p "(search up)" "send -X search-backward-incremental \"%%%\""
      bind-key    -T copy-mode    C-s                  command-prompt -i -I "#{pane_search_string}" -p "(search down)" "send -X search-forward-incremental \"%%%\""
      bind-key    -T copy-mode    C-v                  send-keys -X page-down
      bind-key    -T copy-mode    C-w                  send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode    Escape               send-keys -X cancel
      bind-key    -T copy-mode    Space                send-keys -X page-down
      bind-key    -T copy-mode    ,                    send-keys -X jump-reverse
      bind-key    -T copy-mode    \;                   send-keys -X jump-again
      bind-key    -T copy-mode    F                    command-prompt -1 -p "(jump backward)" "send -X jump-backward \"%%%\""
      bind-key    -T copy-mode    N                    send-keys -X search-reverse
      bind-key    -T copy-mode    R                    send-keys -X rectangle-toggle
      bind-key    -T copy-mode    T                    command-prompt -1 -p "(jump to backward)" "send -X jump-to-backward \"%%%\""
      bind-key    -T copy-mode    f                    command-prompt -1 -p "(jump forward)" "send -X jump-forward \"%%%\""
      bind-key    -T copy-mode    g                    command-prompt -p "(goto line)" "send -X goto-line \"%%%\""
      bind-key    -T copy-mode    n                    send-keys -X search-again
      bind-key    -T copy-mode    q                    send-keys -X cancel
      bind-key    -T copy-mode    t                    command-prompt -1 -p "(jump to forward)" "send -X jump-to-forward \"%%%\""
      bind-key    -T copy-mode    MouseDown1Pane       select-pane
      bind-key    -T copy-mode    MouseDrag1Pane       select-pane \; send-keys -X begin-selection
      bind-key    -T copy-mode    MouseDragEnd1Pane    send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode    WheelUpPane          select-pane \; send-keys -X -N 5 scroll-up
      bind-key    -T copy-mode    WheelDownPane        select-pane \; send-keys -X -N 5 scroll-down
      bind-key    -T copy-mode    DoubleClick1Pane     select-pane \; send-keys -X select-word
      bind-key    -T copy-mode    TripleClick1Pane     select-pane \; send-keys -X select-line
      bind-key    -T copy-mode    Home                 send-keys -X start-of-line
      bind-key    -T copy-mode    End                  send-keys -X end-of-line
      bind-key    -T copy-mode    NPage                send-keys -X page-down
      bind-key    -T copy-mode    PPage                send-keys -X page-up
      bind-key    -T copy-mode    Up                   send-keys -X cursor-up
      bind-key    -T copy-mode    Down                 send-keys -X cursor-down
      bind-key    -T copy-mode    Left                 send-keys -X cursor-left
      bind-key    -T copy-mode    Right                send-keys -X cursor-right
      bind-key    -T copy-mode    M-C-b                send-keys -X previous-matching-bracket
      bind-key    -T copy-mode    M-C-f                send-keys -X next-matching-bracket
      bind-key    -T copy-mode    M-1                  command-prompt -N -I 1 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-2                  command-prompt -N -I 2 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-3                  command-prompt -N -I 3 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-4                  command-prompt -N -I 4 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-5                  command-prompt -N -I 5 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-6                  command-prompt -N -I 6 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-7                  command-prompt -N -I 7 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-8                  command-prompt -N -I 8 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-9                  command-prompt -N -I 9 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode    M-<                  send-keys -X history-top
      bind-key    -T copy-mode    M->                  send-keys -X history-bottom
      bind-key    -T copy-mode    M-R                  send-keys -X top-line
      bind-key    -T copy-mode    M-b                  send-keys -X previous-word
      bind-key    -T copy-mode    M-f                  send-keys -X next-word-end
      bind-key    -T copy-mode    M-m                  send-keys -X back-to-indentation
      bind-key    -T copy-mode    M-r                  send-keys -X middle-line
      bind-key    -T copy-mode    M-v                  send-keys -X page-up
      bind-key    -T copy-mode    M-w                  send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode    "M-{"                send-keys -X previous-paragraph
      bind-key    -T copy-mode    "M-}"                send-keys -X next-paragraph
      bind-key    -T copy-mode    M-Up                 send-keys -X halfpage-up
      bind-key    -T copy-mode    M-Down               send-keys -X halfpage-down
      bind-key    -T copy-mode    C-Up                 send-keys -X scroll-up
      bind-key    -T copy-mode    C-Down               send-keys -X scroll-down
      bind-key    -T copy-mode-vi C-b                  send-keys -X page-up
      bind-key    -T copy-mode-vi C-c                  send-keys -X cancel
      bind-key    -T copy-mode-vi C-d                  send-keys -X halfpage-down
      bind-key    -T copy-mode-vi C-e                  send-keys -X scroll-down
      bind-key    -T copy-mode-vi C-f                  send-keys -X page-down
      bind-key    -T copy-mode-vi C-h                  send-keys -X cursor-left
      bind-key    -T copy-mode-vi C-j                  send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode-vi Enter                send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode-vi C-u                  send-keys -X halfpage-up
      bind-key    -T copy-mode-vi C-v                  send-keys -X rectangle-toggle
      bind-key    -T copy-mode-vi C-y                  send-keys -X scroll-up
      bind-key    -T copy-mode-vi Escape               send-keys -X clear-selection
      bind-key    -T copy-mode-vi Space                send-keys -X begin-selection
      bind-key    -T copy-mode-vi \#                   send-keys -FX search-backward "#{copy_cursor_word}"
      bind-key    -T copy-mode-vi \$                   send-keys -X end-of-line
      bind-key    -T copy-mode-vi %                    send-keys -X next-matching-bracket
      bind-key    -T copy-mode-vi *                    send-keys -FX search-forward "#{copy_cursor_word}"
      bind-key    -T copy-mode-vi ,                    send-keys -X jump-reverse
      bind-key    -T copy-mode-vi /                    command-prompt -p "(search down)" "send -X search-forward \"%%%\""
      bind-key    -T copy-mode-vi 0                    send-keys -X start-of-line
      bind-key    -T copy-mode-vi 1                    command-prompt -N -I 1 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 2                    command-prompt -N -I 2 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 3                    command-prompt -N -I 3 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 4                    command-prompt -N -I 4 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 5                    command-prompt -N -I 5 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 6                    command-prompt -N -I 6 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 7                    command-prompt -N -I 7 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 8                    command-prompt -N -I 8 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi 9                    command-prompt -N -I 9 -p (repeat) "send -N \"%%%\""
      bind-key    -T copy-mode-vi :                    command-prompt -p "(goto line)" "send -X goto-line \"%%%\""
      bind-key    -T copy-mode-vi \;                   send-keys -X jump-again
      bind-key    -T copy-mode-vi ?                    command-prompt -p "(search up)" "send -X search-backward \"%%%\""
      bind-key    -T copy-mode-vi A                    send-keys -X append-selection-and-cancel
      bind-key    -T copy-mode-vi B                    send-keys -X previous-space
      bind-key    -T copy-mode-vi D                    send-keys -X copy-end-of-line
      bind-key    -T copy-mode-vi E                    send-keys -X next-space-end
      bind-key    -T copy-mode-vi F                    command-prompt -1 -p "(jump backward)" "send -X jump-backward \"%%%\""
      bind-key    -T copy-mode-vi G                    send-keys -X history-bottom
      bind-key    -T copy-mode-vi H                    send-keys -X top-line
      bind-key    -T copy-mode-vi J                    send-keys -X scroll-down
      bind-key    -T copy-mode-vi K                    send-keys -X scroll-up
      bind-key    -T copy-mode-vi L                    send-keys -X bottom-line
      bind-key    -T copy-mode-vi M                    send-keys -X middle-line
      bind-key    -T copy-mode-vi N                    send-keys -X search-reverse
      bind-key    -T copy-mode-vi T                    command-prompt -1 -p "(jump to backward)" "send -X jump-to-backward \"%%%\""
      bind-key    -T copy-mode-vi V                    send-keys -X select-line
      bind-key    -T copy-mode-vi W                    send-keys -X next-space
      bind-key    -T copy-mode-vi ^                    send-keys -X back-to-indentation
      bind-key    -T copy-mode-vi b                    send-keys -X previous-word
      bind-key    -T copy-mode-vi e                    send-keys -X next-word-end
      bind-key    -T copy-mode-vi f                    command-prompt -1 -p "(jump forward)" "send -X jump-forward \"%%%\""
      bind-key    -T copy-mode-vi g                    send-keys -X history-top
      bind-key    -T copy-mode-vi h                    send-keys -X cursor-left
      bind-key    -T copy-mode-vi j                    send-keys -X cursor-down
      bind-key    -T copy-mode-vi k                    send-keys -X cursor-up
      bind-key    -T copy-mode-vi l                    send-keys -X cursor-right
      bind-key    -T copy-mode-vi n                    send-keys -X search-again
      bind-key    -T copy-mode-vi o                    send-keys -X other-end
      bind-key    -T copy-mode-vi q                    send-keys -X cancel
      bind-key    -T copy-mode-vi t                    command-prompt -1 -p "(jump to forward)" "send -X jump-to-forward \"%%%\""
      bind-key    -T copy-mode-vi v                    send-keys -X rectangle-toggle
      bind-key    -T copy-mode-vi w                    send-keys -X next-word
      bind-key    -T copy-mode-vi \{                   send-keys -X previous-paragraph
      bind-key    -T copy-mode-vi \}                   send-keys -X next-paragraph
      bind-key    -T copy-mode-vi MouseDown1Pane       select-pane
      bind-key    -T copy-mode-vi MouseDrag1Pane       select-pane \; send-keys -X begin-selection
      bind-key    -T copy-mode-vi MouseDragEnd1Pane    send-keys -X copy-selection-and-cancel
      bind-key    -T copy-mode-vi WheelUpPane          select-pane \; send-keys -X -N 5 scroll-up
      bind-key    -T copy-mode-vi WheelDownPane        select-pane \; send-keys -X -N 5 scroll-down
      bind-key    -T copy-mode-vi DoubleClick1Pane     select-pane \; send-keys -X select-word
      bind-key    -T copy-mode-vi TripleClick1Pane     select-pane \; send-keys -X select-line
      bind-key    -T copy-mode-vi BSpace               send-keys -X cursor-left
      bind-key    -T copy-mode-vi NPage                send-keys -X page-down
      bind-key    -T copy-mode-vi PPage                send-keys -X page-up
      bind-key    -T copy-mode-vi Up                   send-keys -X cursor-up
      bind-key    -T copy-mode-vi Down                 send-keys -X cursor-down
      bind-key    -T copy-mode-vi Left                 send-keys -X cursor-left
      bind-key    -T copy-mode-vi Right                send-keys -X cursor-right
      bind-key    -T copy-mode-vi C-Up                 send-keys -X scroll-up
      bind-key    -T copy-mode-vi C-Down               send-keys -X scroll-down
      bind-key    -T prefix       C-b                  send-prefix
      bind-key    -T prefix       C-o                  rotate-window
      bind-key    -T prefix       C-z                  suspend-client
      bind-key    -T prefix       Space                next-layout
      bind-key    -T prefix       !                    break-pane
      bind-key    -T prefix       \"                   split-window
      bind-key    -T prefix       \#                   list-buffers
      bind-key    -T prefix       \$                   command-prompt -I "#S" "rename-session -- '%%'"
      bind-key    -T prefix       %                    split-window -h
      bind-key    -T prefix       &                    confirm-before -p "kill-window #W? (y/n)" kill-window
      bind-key    -T prefix       \'                   command-prompt -p index "select-window -t ':%%'"
      bind-key    -T prefix       (                    switch-client -p
      bind-key    -T prefix       )                    switch-client -n
      bind-key    -T prefix       ,                    command-prompt -I "#W" "rename-window -- '%%'"
      bind-key    -T prefix       -                    delete-buffer
      bind-key    -T prefix       .                    command-prompt "move-window -t '%%'"
      bind-key    -T prefix       /                    command-prompt -k -p key "list-keys -1N \"%%%\""
      bind-key    -T prefix       0                    select-window -t :=0
      bind-key    -T prefix       1                    select-window -t :=1
      bind-key    -T prefix       2                    select-window -t :=2
      bind-key    -T prefix       3                    select-window -t :=3
      bind-key    -T prefix       4                    select-window -t :=4
      bind-key    -T prefix       5                    select-window -t :=5
      bind-key    -T prefix       6                    select-window -t :=6
      bind-key    -T prefix       7                    select-window -t :=7
      bind-key    -T prefix       8                    select-window -t :=8
      bind-key    -T prefix       9                    select-window -t :=9
      bind-key    -T prefix       :                    command-prompt
      bind-key    -T prefix       \;                   last-pane
      bind-key    -T prefix       <                    display-menu -T "#[align=centre]#{window_index}:#{window_name}" -x W -y S "Swap Left" l "swap-window -t:-1" "Swap Right" r "swap-window -t:+1" "#{?pane_marked_set,,-}Swap Marked" s swap-window  Kill X kill-window Respawn R "respawn-window -k" "#{?pane_marked,Unmark,Mark}" m "select-pane -m" Rename n "command-prompt -I \"#W\" \"rename-window -- '%%'\""  "New After" w "new-window -a" "New At End" W new-window
      bind-key    -T prefix       =                    choose-buffer -Z
      bind-key    -T prefix       >                    display-menu -T "#[align=centre]#{pane_index} (#{pane_id})" -x P -y P "#{?mouse_word,Search For #[underscore]#{=/9/...:mouse_word},}" C-r "copy-mode -t=; send -Xt= search-backward \"#{q:mouse_word}\"" "#{?mouse_word,Type #[underscore]#{=/9/...:mouse_word},}" C-y "send-keys -l -- \"#{q:mouse_word}\"" "#{?mouse_word,Copy #[underscore]#{=/9/...:mouse_word},}" c "set-buffer -- \"#{q:mouse_word}\"" "#{?mouse_line,Copy Line,}" l "set-buffer -- \"#{q:mouse_line}\""  "Horizontal Split" h "split-window -h" "Vertical Split" v "split-window -v"  "Swap Up" u "swap-pane -U" "Swap Down" d "swap-pane -D" "#{?pane_marked_set,,-}Swap Marked" s swap-pane  Kill X kill-pane Respawn R "respawn-pane -k" "#{?pane_marked,Unmark,Mark}" m "select-pane -m" "#{?window_zoomed_flag,Unzoom,Zoom}" z "resize-pane -Z"
      bind-key    -T prefix       ?                    list-keys -N
      bind-key    -T prefix       D                    choose-client -Z
      bind-key    -T prefix       E                    select-layout -E
      bind-key    -T prefix       L                    switch-client -l
      bind-key    -T prefix       M                    select-pane -M
      bind-key    -T prefix       [                    copy-mode
      bind-key    -T prefix       ]                    paste-buffer
      bind-key    -T prefix       c                    new-window
      bind-key    -T prefix       d                    detach-client
      bind-key    -T prefix       f                    command-prompt "find-window -Z -- '%%'"
      bind-key    -T prefix       i                    display-message
      bind-key    -T prefix       l                    last-window
      bind-key    -T prefix       m                    select-pane -m
      bind-key    -T prefix       n                    next-window
      bind-key    -T prefix       o                    select-pane -t :.+
      bind-key    -T prefix       p                    previous-window
      bind-key    -T prefix       q                    display-panes
      bind-key    -T prefix       r                    refresh-client
      bind-key    -T prefix       s                    choose-tree -Zs
      bind-key    -T prefix       t                    clock-mode
      bind-key    -T prefix       w                    choose-tree -Zw
      bind-key    -T prefix       x                    confirm-before -p "kill-pane #P? (y/n)" kill-pane
      bind-key    -T prefix       z                    resize-pane -Z
      bind-key    -T prefix       \{                   swap-pane -U
      bind-key    -T prefix       \}                   swap-pane -D
      bind-key    -T prefix       \~                   show-messages
      bind-key -r -T prefix       DC                   refresh-client -c
      bind-key    -T prefix       PPage                copy-mode -u
      bind-key -r -T prefix       Up                   select-pane -U
      bind-key -r -T prefix       Down                 select-pane -D
      bind-key -r -T prefix       Left                 select-pane -L
      bind-key -r -T prefix       Right                select-pane -R
      bind-key    -T prefix       M-1                  select-layout even-horizontal
      bind-key    -T prefix       M-2                  select-layout even-vertical
      bind-key    -T prefix       M-3                  select-layout main-horizontal
      bind-key    -T prefix       M-4                  select-layout main-vertical
      bind-key    -T prefix       M-5                  select-layout tiled
      bind-key    -T prefix       M-n                  next-window -a
      bind-key    -T prefix       M-o                  rotate-window -D
      bind-key    -T prefix       M-p                  previous-window -a
      bind-key -r -T prefix       M-Up                 resize-pane -U 5
      bind-key -r -T prefix       M-Down               resize-pane -D 5
      bind-key -r -T prefix       M-Left               resize-pane -L 5
      bind-key -r -T prefix       M-Right              resize-pane -R 5
      bind-key -r -T prefix       C-Up                 resize-pane -U
      bind-key -r -T prefix       C-Down               resize-pane -D
      bind-key -r -T prefix       C-Left               resize-pane -L
      bind-key -r -T prefix       C-Right              resize-pane -R
      bind-key -r -T prefix       S-Up                 refresh-client -U 10
      bind-key -r -T prefix       S-Down               refresh-client -D 10
      bind-key -r -T prefix       S-Left               refresh-client -L 10
      bind-key -r -T prefix       S-Right              refresh-client -R 10

      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      # Unbind default keys
      unbind C-b
      unbind '"'
      unbind %

      set -g prefix 'M-\'
      bind -N "Send the prefix key through to the application" 'M-\' send-prefix

      # split panes
      bind "\\" split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      # full window width or height splits
      bind | split-window -fh -c "#{pane_current_path}"
      bind _ split-window -fv -c "#{pane_current_path}"

      # Vim style pane selection
      bind -r -T prefix h resize-pane -L
      bind -r -T prefix j resize-pane -D
      bind -r -T prefix k resize-pane -U
      bind -r -T prefix l resize-pane -R

      # Use Alt-vim keys without prefix key to switch panes
      bind -T root M-h select-pane -L
      bind -T root M-j select-pane -D
      bind -T root M-k select-pane -U
      bind -T root M-l select-pane -R
      bind -T root M-i select-pane -l     # last pane
      bind -T root M-o select-pane -t :.+ # cycle through panes
      # Alt-Arrow keys
      bind -T root M-Left select-pane -L
      bind -T root M-Down select-pane -D
      bind -T root M-Up select-pane -U
      bind -T root M-Right select-pane -R

      # vi keys for copy mode + more bindings for variety and convenience
      # copy mode things
      set -g mode-keys vi
      bind -T root         M-\[ copy-mode
      bind -T root         M-\{ copy-mode \; send -X begin-selection \; send -X search-backward [❯@] # select up to our last command
      bind -T root         M-\} copy-mode \; send -X begin-selection \; send -X search-forward [❯@] # searching forward
      bind -T copy-mode-vi [    send -X search-backward [❯@] # so it's repeatable in copy-mode
      bind -T copy-mode-vi ]    send -X search-forward [❯@] # so it's repeatable in copy-mode
      bind -T copy-mode-vi v    send -X begin-selection
      bind -T copy-mode-vi r    send -X rectangle-toggle
      bind -T copy-mode-vi C-v  send -X begin-selection \; send -X rectangle-toggle
      bind -T root         M-v  run-shell tmux-vim-copy-pane # it's like copy-mode-vi, but to the XTREME; see my comments in that file

      # yank and paste
      bind -T copy-mode-vi y     send -X copy-selection
      bind -T copy-mode-vi Enter send -X copy-selection-and-cancel

      set -g status-position top
    '';
  };# 
}
