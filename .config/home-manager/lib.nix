{ system
, pkgs
, lib
, ...
}:

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

  activationScripts = scripts:
    let
      run = script: lib.hm.dag.entryAfter [
        "installPackages"
        "onFilesChange"
        "reloadSystemd"
      ] ''
        # can't use config.home.path so rely on .nix-profile
        export PATH="/bin:/usr/bin:$HOME/.nix-profile/bin:$PATH"
        ${script}
      '';

      # if the given script is one line, use that as the name of the activation
      # entry. otherwise, hash the arbitrary script content to get a name.
      # prepend an index so the scripts run in the same order as they're defined
      # in the list (nix sorts the entries)
      condense = i: script: {
        value = run script;
        name =
          let
            base =
              if (lib.strings.hasInfix "\n" script)
              then builtins.hashString "md5" script
              else script;
          in
          "[${toString i}] ${base}";
      };
    in
    builtins.listToAttrs (lib.lists.imap0 condense scripts);
}
