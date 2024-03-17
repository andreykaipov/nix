handy stuff

refs:
https://teu5us.github.io/nix-lib.html
https://nixos.org/manual/nix/stable/language/builtins.html#builtins-readDir
https://ryantm.github.io/nixpkgs/functions/library/attrsets/#function-library-lib.attrsets.mapAttrsToList
https://ryantm.github.io/nixpkgs/functions/library/lists/#function-library-lib.lists.forEach

### home manager switch

first run, make sure oyu get the master.pem key from 1password and put it in `/tmp/age.decryption.key.pem`

```console
❯ export NIX_CONF_DIR=~/gh/self/nix
❯ nix run home-manager -- switch --flake ~/gh/self/nix#dustbox
```

subsequent runs

```console
❯ home-manager switch --flake ~/gh/self/nix#dustbox
```

### dry run

We can do a dry run by passing the `-n` flag to `home-manager`, but this will still invoke our activation scripts.
To get a fully dry run without changing home state, we must set `DRY_RUN_ACTIVATION=1` and invoke it with `--impure`:

```console
❯ DRY_RUN=1 home-manager --impure switch --flake ~/.config/home-manager#dustbox -n
```
