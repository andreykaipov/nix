{
  ...
}:

{
  # Screen lock: require password immediately when screensaver activates
  system.defaults.screensaver = {
    askForPassword = true;
    askForPasswordDelay = 0;
  };

  # Per-profile (battery vs AC) sleep settings via pmset.
  #
  # nix-darwin's power.sleep.* uses `systemsetup` which sets a single global
  # value. We need `pmset -b` (battery) and `pmset -c` (charger) for different
  # timeouts per power source.
  system.activationScripts.postActivation.text = ''
    echo "configuring power management..."

    # Battery: display sleeps after 30 min, system sleeps after 1 min idle
    pmset -b displaysleep 30
    pmset -b sleep 1

    # AC power: display sleeps after 120 min, system never sleeps
    pmset -c displaysleep 120
    pmset -c sleep 0
  '';
}
