# nix

Nix configuration for my macOS systems and home environment.

## Architecture

The configuration is split into two independent layers:

| Layer | Purpose | Command |
|---|---|---|
| **nix-darwin** | macOS system config (defaults, homebrew, dock) | `nix run .#switch-darwin` |
| **home-manager** | User environment (shell, git, tmux, neovim, packages) | `nix run .#switch-home` |

These are fully independent — changing your shell config doesn't require a
darwin rebuild, and vice versa.

## Bootstrapping a New Machine

### TL;DR

```sh
# 1. Install Nix
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. Bootstrap (blocking, expects input from you)
nix run --refresh github:andreykaipov/nix#bootstrap -- <host>

# 3. Build and switch everything
cd ~/gh/nix && nix run .#switch
```

### Prerequisites

- macOS on Apple Silicon (aarch64-darwin)

### Step-by-step

#### 1. Install Determinate Nix

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

[Determinate Nix](https://docs.determinate.systems/ds-nix/how-to/install/)
comes with flakes enabled by default and manages the Nix daemon itself. Because
of this, `nix.enable = false` is set in the nix-darwin config — nix-darwin
won't try to manage the daemon, settings, or garbage collection.

#### 2. Bootstrap

Sets the hostname, generates a per-host SSH key, and uploads it to GitHub — all
in one command:

```sh
nix run .#bootstrap <host>
```

Give the host a distinguishable name, like `airfryer`, or `toaster`, or `goonermania`.
The hostname determines which host config under [`hosts/`](./hosts) is used. If the host's
config doesn't exist yet, the script creates one automatically.

The bootstrap script will:

1. Set the machine hostname
2. Generate a new host under `hosts`
3. Generate a per-host SSH key at `~/.ssh/<host>.pem`
4. Upload the public key to GitHub (the `gh` CLI will prompt you)
5. Commit these changes back up to `~/gh/nix`

#### 3a. Build and switch nix-darwin

```sh
nix run .#switch-darwin
```

This will prompt for your `sudo` password. On the first run, `darwin-rebuild`
isn't in your PATH yet, so the script bootstraps it via
`nix run nix-darwin -- switch`. After the first run, `darwin-rebuild` is
available directly.

This:

- Configures macOS system defaults (keyboard, Finder, trackpad, security)
- Installs homebrew and all casks/brews (GUI apps go into `/Applications/`)
- Sets up the Dock layout
- Launches Rectangle (and any other apps that need a first run to register
  their login items)

> **Note:** GUI apps are installed via homebrew casks, not nix packages.
> Home-manager app linking into `/Applications/` is disabled.

#### 3b. Build and switch home-manager

```sh
nix run .#switch-home
```

On the first run, `home-manager` isn't in your PATH yet, so the script
bootstraps it via `nix run home-manager`. After the first run,
`home-manager switch --flake .#<hostname>` is available directly.

This
sets up:

- zsh with powerlevel10k
- git config
- SSH config and keys
- tmux
- neovim (with auto-installed plugins via MiniDeps)
- direnv + nix-direnv
- User packages (dev tools, LSPs, etc.)
- User scripts in `~/bin`
- WezTerm terminal config

Or run both steps at once:

```sh
nix run .#switch
```

## Secret Environment Variables

You can store secret environment variables that get sourced by zsh on
shell startup. Create a file named `zshenv.<name>` under
`modules/home/shell/config/` — for example:

```sh
# modules/home/shell/config/zshenv.work
export CORP_API_TOKEN=sk-abc123
export WORK_NPM_TOKEN=npm_xyz789
```

These plaintext files are gitignored. They live only on the machine where
you create them. On shell startup, zsh sources all `zshenv*` files from
the config directory.

## Adding a New Host

The bootstrap script will create a host config for you automatically,
but if you want to do it yourself, you can.
 
1. Create a directory under `hosts/` matching the machine's hostname:

```sh
mkdir -p hosts/my-machine
```

2. Add a `default.nix` with at least `system` and `username`:

```nix
{
  lib,
  ...
}:
{
  system = "aarch64-darwin";
  username = "myuser";
  publicKey = "ssh-ed25519 AAAA...";
  extraModules = with lib.extras; [
    # dev         # all dev tools at once
    # dev.go      # just Go
    # dev.cloud   # kubectl, awscli2
  ];
}
```

3. Set the machine's hostname to match, then run `nix run .#switch`.

## Directory Structure

```
.
├── flake.nix          # Flake entrypoint
├── lib/               # Helper functions (mkConfig, mkApp, discoverModules)
├── hosts/             # Per-host config (system, username, publicKey, extraModules)
├── modules/
│   ├── darwin/        # Core nix-darwin modules (system defaults, homebrew, dock, etc.)
│   ├── home/          # Core home-manager modules (shell, git, ssh, tmux, nvim, etc.)
│   └── extra/         # Opt-in modules, picked per-host via extraModules
│       └── dev/       # Development tools (go, lua, nix, terraform, cloud, docker, etc.)
└── apps/
    └── aarch64-darwin/ # App scripts (switch, switch-darwin, switch-home, bootstrap, etc.)
```

Core modules under `modules/home/` and `modules/darwin/` are auto-discovered
and applied to every host. Extra modules under `modules/extra/` are opt-in —
each host chooses what it needs via `extraModules`.

To add a new extra module, create a directory under `modules/extra/` with a
`home.nix` and/or `darwin.nix`. It will be auto-discovered as `lib.extras.<name>`.
Nested directories are supported (e.g., `modules/extra/dev/go/home.nix` becomes
`lib.extras.dev.go`). Parent directories aggregate their children, so
`lib.extras.dev` includes all dev sub-modules at once.

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

In any darwin module, but most likely would go in `modules/darwin/homebrew/default.nix`:

```nix
homebrew.casks = [
  "docker-desktop"
  "wezterm"
  "my-new-app"  # add here
];
```

Then `nix run .#switch-darwin`.

### Adding a user package

In any home module, but most likely would go in `modules/home/packages/default.nix`:

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

### Flake management

The `flake.lock` pins every input to a specific revision. Inputs share
`nixpkgs` via `follows` so there's only one copy in the closure — but the
pinned revision can go stale. Update regularly:

```sh
# Update everything (nixpkgs, home-manager, neovim-nightly, etc.)
nix flake update

# Update just nixpkgs (e.g. to pick up a new package version)
nix flake update nixpkgs

# Update a single input
nix flake update home-manager
```

After updating, rebuild with `nix run .#switch` to activate the new versions.
Commit the updated `flake.lock` so other machines get the same pins.

> **Tip:** If a build fails after updating nixpkgs, check whether a transitive
> dependency (like `llm-agents`) needs a package that only exists in a newer
> nixpkgs. Updating nixpkgs to the latest unstable usually fixes it.

### Garbage collection

```sh
nix run .#clean   # removes generations older than 30 days
```

### Rolling back nix-darwin

```sh
nix run .#rollback   # lists generations, prompts for which to restore
```
