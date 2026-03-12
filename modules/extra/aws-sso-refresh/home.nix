{
  host,
  ...
}:

{
  home.file."bin-extra/aws-sso-refresh" = host.symlinkTo ./aws-sso-refresh;

  # Silently refreshes AWS SSO tokens every 30 min via OIDC refresh_token grant.
  #   launchctl start aws-sso-refresh                # trigger now
  #   tail -f ~/Library/Logs/aws-sso-refresh.log     # view logs
  launchd.agents.aws-sso-refresh = host.mkLaunchdAgent {
    name = "aws-sso-refresh";
    interval = 1800;
  };
}
