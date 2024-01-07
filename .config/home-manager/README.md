handy stuff

refs:
https://teu5us.github.io/nix-lib.html
https://nixos.org/manual/nix/stable/language/builtins.html#builtins-readDir
https://ryantm.github.io/nixpkgs/functions/library/attrsets/#function-library-lib.attrsets.mapAttrsToList
https://ryantm.github.io/nixpkgs/functions/library/lists/#function-library-lib.lists.forEach

### home manager switch

```console
❯ nix run home-manager/release-23.11 -- switch --flake ~/.config/home-manager#dustbox
❯ home-manager switch --flake ~/.config/home-manager#dustbox
```

### dry run

We can do a dry run by passing the `-n` flag to `home-manager`, but this will still invoke our activation scripts.
To get a fully dry run without changing home state, we must set `DRY_RUN_ACTIVATION=1` and invoke it with `--impure`:

```console
❯ DRY_RUN=1 home-manager --impure switch --flake ~/.config/home-manager#dustbox -n
```
