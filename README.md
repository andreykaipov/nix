# nixos-config

Nix configuration for my macOS system and home environment.

## Architecture

The configuration is split into two independent layers:

| Layer | Purpose | Command |
|---|---|---|
| **nix-darwin** | macOS system config (defaults, homebrew, dock, secrets) | `nix run .#switch-darwin` |
| **home-manager** | User environment (shell, git, tmux, neovim, packages) | `nix run .#switch-home` |

These are fully independent — changing your shell config doesn't require a darwin rebuild, and vice versa.

## Fresh Install

### Prerequisites

- [Nix](https://nixos.org/download) installed (with flakes enabled)
- SSH key added to GitHub (to clone this repo and the secrets repo)

### 1. Set the hostname

The hostname determines which host config under `hosts/` is used. Set it to
match an existing host directory (e.g. `airfryer`, `toaster`):

```sh
sudo scutil --set LocalHostName airfryer
sudo scutil --set HostName airfryer
```

### 2. Clone and enter the repo

```sh
git clone git@github.com:andreykaipov/nixos-config.git ~/gh/nixos-config
cd ~/gh/nixos-config
```

### 3. Build and switch nix-darwin

This sets up macOS system defaults, homebrew casks, dock layout, and agenix
secrets:

```sh
nix run .#switch-darwin
```

> **Note:** GUI apps are installed via homebrew casks into `/Applications/`,
> not through Nix. Home-manager app linking is disabled since GUI apps come
> from homebrew, not nix packages.

### 4. Build and switch home-manager

This sets up your shell (zsh), git, ssh, tmux, neovim, and user packages:

```sh
nix run .#switch-home
```

Or run both at once:

```sh
nix run .#switch
```

After the first run, `home-manager` is in your PATH (via
`programs.home-manager.enable`), so subsequent runs can use
`home-manager switch --flake .#<hostname>` directly.

## Adding a New Host

1. Create a directory under `hosts/` matching the machine's hostname:

```sh
mkdir -p hosts/my-machine
```

2. Add a `default.nix`:

```nix
{ ... }:

{
  system = "aarch64-darwin";
  username = "myuser";
}
```

`homeDirectory` and `gitRoot` are derived automatically from `system` and `username`.

3. Set the machine's hostname and run the build commands.

The host is auto-discovered — no changes to `flake.nix` needed.

## Directory Structure

```
.
├── flake.nix                 # Flake entrypoint: inputs, outputs
├── lib/                      # Helper functions (mkConfig, mkApp)
├── hosts/                    # Per-host config (system, username)
│   ├── airfryer/             # macOS host
│   └── toaster/              # macOS host
├── modules/
│   ├── darwin/               # nix-darwin modules (system-level)
│   │   ├── default.nix       # Hub: imports all darwin sub-modules
│   │   ├── dock/
│   │   │   ├── default.nix   # dockutil module (options + activation script)
│   │   │   └── settings/     # Dock appearance + entries
│   │   ├── homebrew/
│   │   │   ├── default.nix   # nix-homebrew setup + taps
│   │   │   └── packages/     # Casks, brews, masApps
│   │   ├── secrets/          # agenix identity paths + secrets
│   │   ├── system/           # macOS defaults (keyboard, finder, trackpad, security)
│   │   └── user/             # User account registration
│   └── home/                 # home-manager modules (user-level)
│       ├── default.nix       # Hub: imports all home sub-modules
│       ├── shell/            # zsh + powerlevel10k
│       ├── git/              # Git config (name, email, signing)
│       ├── ssh/              # SSH config
│       ├── packages/         # User packages (dev tools, LSPs, etc.)
│       ├── tmux/             # tmux configuration
│       └── nvim/             # Neovim configuration
└── apps/
    └── aarch64-darwin/       # App scripts (nix run .#<name>)
        ├── switch            # Build and switch both darwin + home
        ├── switch-darwin     # Build and switch nix-darwin
        ├── switch-home       # Switch home-manager configuration
        ├── clean             # Garbage collect old generations (>30 days)
        └── rollback          # Roll back to a previous darwin generation
```

## Day-to-Day Usage

### Rebuild after config changes

```sh
# System changes (macOS defaults, homebrew, dock, etc.)
nix run .#switch-darwin

# Home environment changes (shell, packages, dotfiles, etc.)
nix run .#switch-home

# Both at once
nix run .#switch
```

### Adding a Homebrew cask

Edit `modules/darwin/homebrew/packages/default.nix`:

```nix
homebrew.casks = [
  "docker-desktop"
  "wezterm"
  "my-new-app"  # add here
];
```

Then `nix run .#switch-darwin`.

### Adding a user package

Edit `modules/home/packages/default.nix`:

```nix
home.packages = with pkgs; [
  ripgrep
  my-new-tool  # add here
];
```

Then `nix run .#switch-home`.

### Symlinking dotfiles for live editing

Home-manager modules can symlink their `~/.config/<name>` directory back into
the repo so edits take effect immediately without rebuilding:

```nix
{ host, ... }:

{
  xdg.configFile."nvim" = host.symlinkTo ./.;
}
```

This creates `~/.config/nvim → ~/gh/nix/modules/home/nvim`. The directory name
is derived from the path you pass in (`./.` resolves to the current module's
directory). See `hosts/extend.nix` for implementation details.

### Garbage collection

```sh
nix run .#clean   # removes generations older than 30 days
```

### Rolling back nix-darwin

```sh
nix run .#rollback   # lists generations, prompts for which to restore
```
