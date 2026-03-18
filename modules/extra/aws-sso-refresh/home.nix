{
  host,
  config,
  ...
}:

let
  logFile = "${host.homeDirectory}/Library/Logs/aws-sso-refresh.log";
in
{
  home.file."bin-extra/aws-sso-refresh" = host.symlinkTo ./aws-sso-refresh;

  launchd.agents.aws-sso-refresh = {
    enable = true;
    config = {
      Label = "aws-sso-refresh";
      ProgramArguments = [ "${host.homeDirectory}/bin-extra/aws-sso-refresh" ];
      StartInterval = 1800;
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
      EnvironmentVariables = {
        PATH = "${config.home.profileDirectory}/bin:/usr/bin";
      };
    };
  };
}
