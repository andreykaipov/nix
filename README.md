# nix

Nix configuration for my macOS systems and home environment.

## Architecture

The configuration is split into two independent layers:

| Layer | Purpose | Command |
|---|---|---|
| **nix-darwin** | macOS system config (defaults, homebrew, dock, secrets) | `nix run .#switch-darwin` |
| **home-manager** | User environment (shell, git, tmux, neovim, packages) | `nix run .#switch-home` |

These are fully independent — changing your shell config doesn't require a darwin rebuild, and vice versa.

## Fresh Install

### Prerequisites

- [Determinate Nix](https://docs.determinate.systems/ds-nix/how-to/install/) installed
- SSH key added to GitHub (to clone this repo and the secrets repo)
- `~/.ssh/keys/agenix` identity key (stored in 1Password)

#### Installing Determinate Nix

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Determinate Nix comes with flakes enabled by default and manages the Nix daemon
itself. Because of this, `nix.enable = false` is set in the nix-darwin config
to avoid conflicts — nix-darwin won't try to manage the Nix daemon, settings,
or garbage collection.

### 1. Set the hostname

The hostname determines which host config under `hosts/` is used. Set it to
match an existing host directory (e.g. `airfryer`, `toaster`):

```sh
sudo scutil --set LocalHostName airfryer
sudo scutil --set HostName airfryer
```

### 2. Clone and enter the repo

```sh
git clone git@github.com:andreykaipov/nix.git ~/gh/nix
cd ~/gh/nix
```

### 3. Place the agenix identity key

Copy `~/.ssh/keys/agenix` from 1Password. This is the only key that needs to be
manually placed — all other SSH keys are encrypted in the
[nix-secrets](https://github.com/andreykaipov/nix-secrets) repo and get
decrypted automatically by agenix during the darwin activation.

```sh
# Paste from 1Password into ~/.ssh/keys/agenix, then:
mkdir -p ~/.ssh/keys
chmod 600 ~/.ssh/keys/agenix
```

### 4. Build and switch nix-darwin

This sets up macOS system defaults, homebrew casks, dock layout, and decrypts
SSH keys via agenix:

```sh
nix run .#switch-darwin
```

> **Note:** GUI apps are installed via homebrew casks into `/Applications/`,
> not through Nix. Home-manager app linking is disabled since GUI apps come
> from homebrew, not nix packages.

### 5. Build and switch home-manager

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
├── lib/                      # Helper functions (mkConfig, mkApp, discoverModules)
├── hosts/                    # Per-host config (system, username)
│   ├── default.nix           # Auto-discovers host dirs → { darwin, linux, home }
│   └── extend.nix            # HM module: injects host.symlinkTo via _module.args
├── modules/
│   ├── _internal/            # Plumbing modules (not user config)
│   │   └── dock.nix          # dockutil module (options + activation script)
│   ├── darwin/               # nix-darwin modules (auto-discovered)
│   │   ├── default.nix       # Auto-imports subdirs via lib.discoverModules
│   │   ├── homebrew/         # nix-homebrew setup, taps, casks, brews
│   │   ├── secrets/          # agenix identity paths + secrets
│   │   ├── system/           # macOS defaults (keyboard, finder, trackpad, security)
│   │   │   └── dock/         # Dock appearance + entries (uses _internal/dock)
│   │   └── user/             # User account registration
│   └── home/                 # home-manager modules (auto-discovered)
│       ├── default.nix       # Auto-imports subdirs via lib.discoverModules
│       ├── bin/              # User scripts (~/bin symlink)
│       ├── bootstrap/        # SSH agent + tmux session bootstrap
│       ├── direnv/           # direnv + nix-direnv
│       ├── git/              # Git config (name, email, signing)
│       ├── nvim/             # Neovim configuration
│       ├── packages/         # User packages (dev tools, LSPs, etc.)
│       ├── shell/            # zsh + powerlevel10k
│       ├── ssh/              # SSH config
│       ├── tmux/             # tmux configuration
│       └── wezterm/          # WezTerm terminal config
└── apps/
    └── aarch64-darwin/       # App scripts (nix run .#<name>)
        ├── switch            # Build and switch both darwin + home
        ├── switch-darwin     # Build and switch nix-darwin
        ├── switch-home       # Switch home-manager configuration
        ├── clean             # Garbage collect old generations (>30 days)
        └── rollback          # Roll back to a previous darwin generation
```

Adding a new module is just creating a subdirectory with a `default.nix` —
`lib.discoverModules` picks it up automatically.

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

Edit `modules/darwin/homebrew/default.nix`:

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
