{ system, pkgs, lib, ... }:

{
  subdirs = dir:
    lib.attrsets.mapAttrsToList (k: v: k)
      (lib.attrsets.filterAttrs (k: v: v == "directory")
        (builtins.readDir dir));

  # find all packages to include
  packages =
    # check our custom packages' meta.platforms to see if we should include it
    let
      dirs = lib.my.subdirs ./packages;
      packagesEvaled = lib.lists.forEach dirs (p: pkgs.callPackage ./packages/${p} { });
      shouldUsePkg = p: lib.meta.availableOn pkgs.stdenv.hostPlatform p;
    in
    builtins.filter shouldUsePkg packagesEvaled;

  # find all overlays to include
  overlays =
    let dirs = lib.my.subdirs ./overlays;
    in lib.lists.forEach dirs (o: import ./overlays/${o});

  homedir = username: (if pkgs.stdenv.isLinux then "/home" else "/Users") + "/${username}";
}
