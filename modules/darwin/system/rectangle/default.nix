{
  ...
}:

{
  system.defaults.CustomUserPreferences."com.knollsoft.Rectangle" = {
    # Launch on login
    launchOnLogin = true;

    # Allow any shortcut (not just preset ones)
    allowAnyShortcut = true;

    # Use alternate default shortcuts
    alternateDefaultShortcuts = true;

    # Disable Sparkle auto-update checks (managed by Homebrew)
    SUEnableAutomaticChecks = false;

    # Show menubar icon
    hideMenubarIcon = false;

    # On repeated execution, cycle through sizes
    subsequentExecutionMode = 1;

    # Landscape snap areas
    landscapeSnapAreas = ''[2,{"action":2},5,{"compound":-3},3,{"action":16},1,{"action":15},4,{"compound":-2},7,{"compound":-4},8,{"action":14},6,{"action":13}]'';

    # Keyboard shortcuts
    # keyCode reference: https://eastmanreference.com/complete-list-of-applescript-key-codes
    # modifierFlags: 1179648 = Ctrl+Option, 1703936 = Ctrl+Option+Cmd, 786432 = Cmd+Option

    # Left Half: Ctrl+Option+Left
    leftHalf = {
      keyCode = 123;
      modifierFlags = 1179648;
    };

    # Right Half: Ctrl+Option+Right
    rightHalf = {
      keyCode = 124;
      modifierFlags = 1179648;
    };

    # Maximize: Ctrl+Option+A
    maximize = {
      keyCode = 0;
      modifierFlags = 1179648;
    };

    # Next Display: Ctrl+Option+Cmd+Right
    nextDisplay = {
      keyCode = 124;
      modifierFlags = 1703936;
    };

    # Previous Display: Ctrl+Option+Cmd+Left
    previousDisplay = {
      keyCode = 123;
      modifierFlags = 1703936;
    };

    # Toggle Todo: Cmd+Option+B
    toggleTodo = {
      keyCode = 11;
      modifierFlags = 786432;
    };

    # Reflow Todo: Cmd+Option+N
    reflowTodo = {
      keyCode = 45;
      modifierFlags = 786432;
    };
  };
}
