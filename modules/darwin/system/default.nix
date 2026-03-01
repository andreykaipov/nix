{
  username,
  ...
}:

{
  system = {
    checks.verifyNixPath = false;
    primaryUser = username;
    stateVersion = 5;

    defaults = {
      NSGlobalDomain = {
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
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=60
  '';
}
