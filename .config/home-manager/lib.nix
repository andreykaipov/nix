{ system, pkgs, lib, ... }:

{
  subdirs = dir:
    lib.attrsets.mapAttrsToList (k: v: k)
      (lib.attrsets.filterAttrs (k: v: v == "directory")
        (builtins.readDir dir));

  # find all packages to include
  # andrey it's cool but pls don't use this
  packages =
    # check our custom packages' meta.platforms to see if we should include it
    let
      dirs = lib.my.subdirs ./packages;
      packagesEvaled = lib.lists.forEach dirs (p: pkgs.callPackage ./packages/${p} { });
      shouldUsePkg = p: lib.meta.availableOn pkgs.stdenv.hostPlatform p;
    in
    builtins.filter shouldUsePkg packagesEvaled;

  # create overlays from custom packages and include any actual overlays
  overlays =
    let
      packages = lib.my.subdirs ./packages;
      overlays = lib.my.subdirs ./overlays;
    in
    lib.lists.forEach packages (p: self: super: { ${p} = pkgs.callPackage ./packages/${p} { }; }) ++
    lib.lists.forEach overlays (o: import ./overlays/${o})
  ;

  homedir = username: (if pkgs.stdenv.isLinux then "/home" else "/Users") + "/${username}";
}
