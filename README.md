## setup

For the first run on a new host, get the `nix/master.pem` key from 1Password
and put it in `/tmp/age.decryption.key.pem`.
Then run:

```console
❯ home/scripts/bin/switch
```

Subsequent runs can then just be `switch`, or just do it directly:

```console
❯ home-manager switch --flake ~/gh/nix#$HOST
```

## dry runs

```console
❯ DRY_RUN=1 switch
```

## refs

It's likely I'll never look at these again because I'll Google the same issue
10 times over and over again, but it's here for the same reason I hoard
bookmarks:

- https://teu5us.github.io/nix-lib.html
- https://nixos.org/manual/nix/stable/language/builtins.html#builtins-readDir
- https://ryantm.github.io/nixpkgs/functions/library/attrsets/#function-library-lib.attrsets.mapAttrsToList
- https://ryantm.github.io/nixpkgs/functions/library/lists/#function-library-lib.lists.forEach
- https://ryantm.github.io/nixpkgs/builders/trivial-builders/#trivial-builder-writeText
