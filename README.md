# nixos-config

Nix configuration for my macOS system and home environment.

## Architecture

The configuration is split into two independent layers:

| Layer | Purpose | Command |
|---|---|---|
| **nix-darwin** | macOS system config (defaults, homebrew, dock, secrets) | `nix run .#build-switch` |
| **home-manager** | User environment (shell, git, tmux, neovim, packages) | `nix run .#home-switch` |

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
nix run .#build-switch
```

### 4. Build and switch home-manager

This sets up your shell (zsh), git, ssh, tmux, neovim, and user packages:

```sh
nix run .#home-switch
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
{ lib, ... }:
let
  homeDirectory = "/Users/myuser";
in
{
  system = "aarch64-darwin";
  username = "myuser";
  inherit homeDirectory;
  gitRoot = "${homeDirectory}/gh/nixos-config";
  extraModules = [];
}
```

3. Set the machine's hostname and run the build commands.

The host is auto-discovered — no changes to `flake.nix` needed.

## Directory Structure

```
.
├── flake.nix              # Flake entrypoint: inputs, outputs
├── lib/                   # Helper functions (mkConfig, mkApp)
├── hosts/                 # Per-host config (system, username, homeDirectory)
│   ├── airfryer/          # macOS host
│   └── toaster/           # macOS host
├── modules/
│   ├── darwin/            # nix-darwin modules (system-level)
│   │   ├── default.nix    # Main darwin module: system defaults, packages
│   │   ├── user.nix       # User account + dock layout
│   │   ├── homebrew.nix   # nix-homebrew taps, casks, brews, masApps
│   │   └── secrets.nix    # agenix secrets
│   ├── home/              # home-manager modules (user-level)
│   │   ├── default.nix    # Main home module: zsh, git, ssh
│   │   ├── packages/      # User packages (dev tools, LSPs, etc.)
│   │   ├── tmux/          # tmux configuration
│   │   └── nvim/          # Neovim configuration
│   ├── shared/            # Shared nixpkgs config (overlays, unfree)
│   └── roots/             # gitRoot option for mkOutOfStoreSymlink
├── apps/
│   └── aarch64-darwin/    # App scripts (nix run .#<name>)
│       ├── build-switch   # Build and switch nix-darwin
│       ├── home-switch    # Switch home-manager configuration
│       ├── clean          # Garbage collect old generations (>7 days)
│       └── rollback       # Roll back to a previous darwin generation
└── overlays/              # Nixpkgs overlays
```

## Day-to-Day Usage

### Rebuild after config changes

```sh
# System changes (macOS defaults, homebrew, dock, etc.)
nix run .#build-switch

# Home environment changes (shell, packages, dotfiles, etc.)
nix run .#home-switch
```

### Adding a Homebrew cask

Edit `modules/darwin/homebrew.nix`:

```nix
homebrew.casks = [
  "docker-desktop"
  "ghostty"
  "my-new-app"  # add here
];
```

Then `nix run .#build-switch`.

### Adding a user package

Edit `modules/home/packages/default.nix`:

```nix
home.packages = with pkgs; [
  ripgrep
  my-new-tool  # add here
];
```

Then `nix run .#home-switch`.

### Garbage collection

```sh
nix run .#clean   # removes generations older than 7 days
```

### Rolling back nix-darwin

```sh
nix run .#rollback   # lists generations, prompts for which to restore
```
