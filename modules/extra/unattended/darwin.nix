{
  host,
  ...
}:

{
  system.defaults.loginwindow = {
    autoLoginUser = host.username;
    DisableConsoleAccess = false;
  };
}
