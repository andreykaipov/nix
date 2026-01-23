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

# 2. Bootstrap (clones repo, sets hostname, generates keys, encrypts secrets)
nix run --refresh github:andreykaipov/nix#bootstrap -- <host>

# 3. Build everything
nix run .#switch
```

### Prerequisites

- macOS on Apple Silicon (aarch64-darwin)
- The agenix identity key from 1Password

### Step-by-step

#### 1. Install Determinate Nix

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

[Determinate Nix](https://docs.determinate.systems/ds-nix/how-to/install/)
comes with flakes enabled by default and manages the Nix daemon itself. Because
of this, `nix.enable = false` is set in the nix-darwin config — nix-darwin
won't try to manage the daemon, settings, or garbage collection.

#### 2. Clone the repo

Clone via HTTPS — the repo is public, so no SSH key is needed yet:

```sh
GIT_CONFIG_GLOBAL=/dev/null nix run nixpkgs#git -- clone https://github.com/andreykaipov/nix.git ~/gh/nix
cd ~/gh/nix
```

No Xcode Command Line Tools needed — git comes straight from nix. The `-c`
flag overrides the HTTPS→SSH rewrite that may exist from a previous
home-manager run.

The repo must live at `~/gh/nix` — this path is used by `host.gitRoot` for
symlinks and module resolution.

#### 3. Bootstrap

Sets the hostname, generates a per-host SSH key, uploads it to GitHub, and
encrypts it into nix-secrets — all in one command:

```sh
nix run .#bootstrap <host>
```

The hostname determines which host config under `hosts/` is used. If the host
directory doesn't exist yet, the script creates one automatically.

The bootstrap script will:

1. Set the machine hostname
2. Prompt you to place the agenix identity key from 1Password into
   `~/.config/agenix/identity` (the **only** manual secret)
3. Generate a per-host SSH key at `~/.ssh/<host>.pem`
4. Upload the public key to GitHub via `gh` CLI
5. Encrypt the private key into nix-secrets and update `flake.lock`

#### 4. Build and switch nix-darwin

```sh
nix run .#switch-darwin
```

This will prompt for your `sudo` password. It builds the nix-darwin
configuration, then runs `darwin-rebuild switch` to apply it. On the first run,
this:

- Configures macOS system defaults (keyboard, Finder, trackpad, security)
- Installs homebrew and all casks/brews (GUI apps go into `/Applications/`)
- Sets up the Dock layout

> **Note:** GUI apps are installed via homebrew casks, not nix packages.
> Home-manager app linking into `/Applications/` is disabled.

#### 5. Build and switch home-manager

```sh
nix run .#switch-home
```

On the first run, `home-manager` isn't in your PATH yet, so the script
bootstraps it via `nix run home-manager`. After the first run,
`home-manager switch --flake .#<hostname>` is available directly.

agenix decrypts the host SSH key from nix-secrets via a LaunchAgent on every
switch. This sets up:

- zsh with powerlevel10k
- git config
- SSH config and agent
- tmux
- neovim
- direnv + nix-direnv
- User packages (dev tools, LSPs, etc.)
- User scripts in `~/bin`
- WezTerm terminal config

Or run both steps at once:

```sh
nix run .#switch
```

#### 6. Post-bootstrap

Open a new terminal (or `exec zsh`) to pick up the new shell environment.
Everything should be ready — shell, editor, packages, and secrets.

## Adding a New Host

1. Create a directory under `hosts/` matching the machine's hostname:

```sh
mkdir -p hosts/my-machine
```

2. Add a `default.nix` with at least `system` and `username`:

```nix
{ ... }:

{
  system = "aarch64-darwin";
  username = "myuser";
}
```

`homeDirectory` and `gitRoot` are derived automatically by `lib.mkHost`:
- darwin → `/Users/<username>/gh/nix`
- linux → `/home/<username>/gh/nix`

You can also pass `extraModules` for host-specific configuration:

```nix
{ ... }:

{
  system = "aarch64-darwin";
  username = "myuser";
  extraModules = [
    # host-specific overrides
  ];
}
```

3. Set the machine's hostname to match, then run `nix run .#switch`.

The host is auto-discovered from the directory name — no changes to `flake.nix`
needed.

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
│   │   ├── system/           # macOS defaults (keyboard, finder, trackpad, security)
│   │   │   └── dock/         # Dock appearance + entries (uses _internal/dock)
│   │   └── user/             # User account registration
│   └── home/                 # home-manager modules (auto-discovered)
│       ├── default.nix       # Auto-imports subdirs via lib.discoverModules
│       ├── bin/              # User scripts (~/bin symlink)
│       ├── direnv/           # direnv + nix-direnv
│       ├── git/              # Git config (name, email, signing)
│       ├── nvim/             # Neovim configuration
│       ├── packages/         # User packages (dev tools, LSPs, etc.)
│       ├── secrets/          # agenix plumbing (identity paths, imports)
│       ├── shell/            # zsh + powerlevel10k
│       ├── ssh/              # SSH config, key management, agenix secrets
│       ├── tmux/             # tmux configuration
│       └── wezterm/          # WezTerm terminal config
└── apps/
    └── aarch64-darwin/       # App scripts (nix run .#<name>)
        ├── switch            # Build and switch both darwin + home
        ├── switch-darwin     # Build and switch nix-darwin
        ├── switch-home       # Switch home-manager configuration
        ├── bootstrap         # Bootstrap a fresh macOS machine end-to-end
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
