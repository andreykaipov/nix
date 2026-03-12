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

    # To discover defaults for an app you want to configure:
    #
    #   $ defaults domains | tr ',' '\n' | grep -i <app>
    #   $ defaults read <domain>
    #
    # Or diff before/after changing a setting in the app's UI:
    #
    #   $ defaults read <domain> > /tmp/before
    #   # ... change the setting in the app ...
    #   $ defaults read <domain> > /tmp/after
    #   $ diff /tmp/before /tmp/after
    #
    # Use `defaults read NSGlobalDomain` for system-wide preferences.
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
    Defaults timestamp_timeout=120
    Defaults !tty_tickets
    ${host.username} ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild, /run/current-system/sw/bin/nix
  '';

  # nix-darwin only executes well-known activation script names. Custom names
  # like "postUserDefaults" or "launchApps" are silently ignored. Use
  # postActivation which runs after defaults, launchd, fonts, etc.
  #
  # postActivation.text is concatenated across modules, so each module
  # (e.g. rectangle/) can append its own snippet.
  system.activationScripts.postActivation.text = ''
    # Restart cfprefsd so preference changes (key repeat, beep, etc.) take
    # effect, then activateSettings to apply input/trackpad/scroll changes,
    # and restart Finder for Finder-specific defaults.
    echo "applying system preferences..."
    killall cfprefsd 2>/dev/null || true
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall Finder 2>/dev/null || true

    # Set a plain black desktop background.
    echo "setting desktop background..."
    osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/System/Library/Desktop Pictures/Solid Colors/Black.png"'
  '';
}
