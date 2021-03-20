## overlays

### what

Overlays allow us to modify existing Nix packages to our convenience.

Maybe we want to change the version of a Nix package (whether it's because
upstream PRs are not merged in but you want to use the newest version now, or
whether it's because you can't be bothered to update your infrastructure so you
need to use outdated software)?

Or maybe we want to compile a package with a custom patches, flags, or
configuration?

### why

In the above we could avoid the use of overlays by creating a new custom
package/derivation copied from the upstream https://github.com/NixOS/nixpkgs
repo. Suppose we add it to `~/.config/nixpkgs/custom/myname/default.nix`. Then
we call it from our `~/.config/nixpkgs/config.nix` using `callPackage
./custom/myname {}`.

We could also create our own Nix channel by forking the upstream nixpkgs repo
and modifying the packages ourselves. Then we'd just import our local fork and
reference packages using it. For example, if we've modified
[`sshuttle`](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/security/sshuttle/default.nix),
and we want to install it from our local fork, we'd have something like:

```nix
{
  local ? import <local> {},
  ...
}: {
  packageOverrides = pkgs: with stable; {
    hello = buildEnv {
      name = "packages-from-local-fork";
      paths = [
        local.sshuttle
      ];
    };
  };
}
```

And run:

```shell
NIX_PATH="$NIX_PATH:local=$HOME/local-nixpkgs" nix-env -iA nixpkgs.hello
```

In both situations, we're maintaining a lot of configuration, even if we just
want to overwrite a small part of a package like add a patch or change
a version, which is very cumbersome.

Overlays allow us to just specify exactly what we want to change. Plus, it's
transparent to Nix, in that we don't need a `callPackage` or `import`. It'll
appear neatly in our package list:

```nix
{
  stable ? import <stable> {},
  ...
}: {
  packageOverrides = pkgs: with stable; {
    hello = buildEnv {
      name = "idk";
      paths = [
        sshuttle
      ];
    };
  };
}
```

### structure

Nix package overlays are automatically read from
`~/.config/nixpkgs/overlays.nix` or from any `*.nix` files in
`~/.config/nixpkgs/overlays` (no matter how deeply nested).

We put each overlay in its own directory. Since Nix recursively traverses
`~/.config/nixpkgs/overlays` for any Nix files, the directory names don't matter
at all. However, it's neater than having all of our overlays in just one
directory since they may include additional files like patches or configuration.

### info

Within an overlay:
- `self` is the final set after applying the overlay
- `super` is the original package set before your overlay is applied

See:
- https://nixos.wiki/wiki/Overlays#Applying_overlays_automatically
- https://blog.flyingcircus.io/2017/11/07/nixos-the-dos-and-donts-of-nixpkgs-overlays/
- https://blog.thomasheartman.com/posts/nix-override-packages-with-overlays
- https://nixos.org/manual/nixpkgs/stable/#how-to-override-a-python-package-using-overlays
