{
  lib,
  host,
  ...
}:

{
  imports = lib.discoverModules ./.;

  system = {
    checks.verifyNixPath = false;
    primaryUser = host.username;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        "com.apple.swipescrolldirection" = false; # "natural" scrolling is off (IT IS NOT NATURAL)
      };

      finder = {
        _FXShowPosixPathInTitle = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=60
  '';

  # Restart cfprefsd after defaults are written so NSGlobalDomain changes
  # (scroll direction, key repeat, etc.) take effect without logging out.
  system.activationScripts.postUserDefaults.text = ''
    echo "restarting cfprefsd..."
    killall cfprefsd 2>/dev/null || true
  '';

  # Launch apps that need a first run to register their login items.
  # Runs as the user since activation scripts execute under sudo.
  system.activationScripts.launchApps.text = ''
    for app in Rectangle; do
      if [ -d "/Applications/$app.app" ] && ! sudo -u ${host.username} pgrep -xq "$app"; then
        echo "launching $app..."
        sudo -u ${host.username} open -a "$app"
      fi
    done
  '';
}
