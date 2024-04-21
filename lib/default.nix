{ pkgs
, lib
, flake
, ...
}:
with builtins;
rec {
  readLineDelimited = contents: map head (filter isList (split "([^\n]+)" contents)) ++ (attrNames hosts);

  # this is pretty janky and i likely don't need it but it was fun to get working
  run = cmd:
    let
      name = "adhoc";
      script = ''
        export PATH=$PATH:/bin:/usr/bin:$HOME/.nix-profile/bin
        ${cmd} >$out
        :
      '';
      f = pkgs.runCommand name { env.when = flake.sourceInfo.lastModified; } script;
    in
    lib.readFile f;

  find = type: dir:
    let
      contents = builtins.readDir dir;
      filtered = lib.attrsets.filterAttrs (_: v: v == type) contents;
    in
    lib.attrsets.mapAttrsToList (k: _: k) filtered;

  subdirs = find "directory";

  files = find "regular";

  # create overlays from custom packages and include any actual overlays
  overlays =
    let
      packages = subdirs ../packages;
      overlays = subdirs ../overlays;
    in
    lib.lists.forEach packages (p: self: super: { ${p} = pkgs.callPackage ../packages/${p} { }; }) ++
    lib.lists.forEach overlays (o: import ../overlays/${o});

  modules = lib.lists.forEach (files ./modules) (m: ../modules/${m});

  homedir = username: (if pkgs.stdenv.isLinux then "/home" else "/Users") + "/${username}";

  # note this will only be read if invoked via --impure
  dry_run = builtins.getEnv "DRY_RUN";

  activationScripts = scripts:
    let
      run = script: lib.hm.dag.entryAfter [
        "installPackages"
        "onFilesChange"
        "reloadSystemd"
      ] ''
        # might not be necessary, could just use home.emptyActivationPath
        # export PATH=$PATH:/bin:/usr/bin:$HOME/.nix-profile/bin
        if [ -n "${dry_run}" ]; then
          echo '#### THIS IS A DRY RUN FOR THE ACTIVATION SCRIPT ####'
          if [ -r "${script}" ]; then
            head -n3 "${script}"
          else
            echo '${script}' | head -n3
          fi
        else
          ${script}
        fi
      '';

      # if the given script is one line, use that as the name of the activation
      # entry. otherwise, hash the arbitrary script content to get a name.
      # prepend an index so the scripts run in the same order as they're defined
      # in the list (nix sorts the entries)
      condense = i: script: {
        value = run script;
        name =
          let
            fname =
              if (lib.strings.hasInfix "\n" script)
              then builtins.hashString "md5" script
              else script;
          in
          "[${toString i}] ${fname}";
      };
    in
    builtins.listToAttrs (lib.lists.imap0 condense scripts);

  vimPluginFromGitHub = repo: ref: rev: pkgs.vimUtils.buildVimPlugin {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
      rev = rev;
    };
  };

  # f = lib.my.templateFile "_bootstrap.sh" ./bootstrap.sh.mustache data;
  # home.file."bin/_bootstrap.sh".source = f;
  # home.file."bin/_bootstrap.sh".text = builtins.readFile f;
  templateFile = name: template: data:
    pkgs.stdenv.mkDerivation {
      name = "${name}-templated";

      nativeBuildInpts = [ pkgs.mustache-go ];

      # Pass Json as file to avoid escaping
      passAsFile = [ "jsonData" ];
      jsonData = builtins.toJSON data;

      # Disable phases which are not needed. In particular the unpackPhase will
      # fail, if no src attribute is set
      phases = [ "buildPhase" "installPhase" ];

      buildPhase = ''
        ${pkgs.mustache-go}/bin/mustache $jsonDataPath ${template} >rendered_file
      '';

      installPhase = ''
        cp rendered_file $out
      '';
    };
}
