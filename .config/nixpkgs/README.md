## nixpkgs

## creating Nix packages

You can do something like:

```nix
with import <nixpkgs> {};
stdenv.mkDerivation {
  ...
}
```

or the more traditional approach of:

```nix
{ pkgs ? import <nixpkgs> {} }: with pkgs;
stdenv.mkDerivation {
  ...
}
```

or the more _extensionable_ traditional approach where we list each individual
thing we're using:

```nix
{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  ...
}
```

---

The first approach has the most convenience, but has the least extensibility.
With the first, you can easily build it with a `nix-build` and import it using
`import ./blah`.

The second and third approaches have to be be built using:

```shell
nix-build -E '(import <nixpkgs> {}).callPackage ./default.nix {}'
```

These derivations are not importable since they're function definitions. So
instead we have to use `callPackage`:

```nix
callPackage ./blah {}
```

And by using `callPackage`, we're able to get `overrideAttrs` from
`mkDerivation` and `override` from `callPackage`.

The third approach is even more extensible because it lets you override the
individual objects `stdenv` and `fetchFromGitHub`.

---

For convenience, this repo uses the first approach because it's *my* home and
I can do whatever I want.

See:
- https://nixos.wiki/wiki/Nixpkgs/Modifying_Packages
- https://discord.com/channels/568306982717751326/570351733780381697/822952054863298582
