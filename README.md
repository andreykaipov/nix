## intro

Hey - this is my home directory.

WHAT? You've made your home directory a Git repository? Are you crazy?

Crazy is subjective, but yes.

## setup

Are you on a new machine? Run the following from your home directory.

```console
$ curl -sLo- https://raw.githubusercontent.com/andreykaipov/home/master/.meta/init.sh | sh -
$ ~/.meta/install.sh
```

Want to reinstall for whatever reason?

```console
$ FORCE_REINSTALL=1 ~/.meta/install.sh
```

## work

_Secret_ work environment variables go in `~/.config/sh/env.work`. When this
file is present, Nix packages under the `forWork` list in
`~/.config/nixpkgs/config.nix` are also installed.

Set the Git email accordingly in `~/.config/git/work`.

## rationale

- Symlinks suck, why bother with them?

- Every tracked file must explicitly exist in our `.gitignore`, so we can't
  accidentally add a file we don't want.

  Since I've neatly organized all the actual configuration under `.config`,
  I take quite a liberal approach by including it all, and just exclude things
  we definitely wouldn't want to commit. Since most programs should recognize
  the XDG base dir, an added benefit now is easily finding any new configuration
  that might have changed or been added recently.

- Setting `GIT_CEILING_DIRECTORIES="$HOME"` prevents Git from working inside
  any non-Git subdirectories within our home directory, so accidentally mucking
  around with this repo is practically impossible unless we're in `$HOME` only.

---

## nix oops?

```console
$ nix-collect-garbage -d
$ nix-store --verify --repair --check-contents
$ FORCE_REINSTALL=1 ~/.meta/install.sh`
```
