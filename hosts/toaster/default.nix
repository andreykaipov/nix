{
  ...
}:
{
  system = "arm64-darwin";
  username = "andrey";
  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFW9lYrlUA5gWMBEBnuMCcVpBLih8KQhizcCNsSPo9U7 ";
  extraDarwinModules = [ ];
  extraHomeModules = [
    (
      { pkgs, host, ... }:
      {
        home.packages = [ pkgs.uv ];
        # Silently refreshes AWS SSO tokens every 30 min via OIDC refresh_token grant.
        #   launchctl start aws-sso-refresh                # trigger now
        #   tail -f ~/Library/Logs/aws-sso-refresh.log     # view logs
        launchd.agents.aws-sso-refresh = host.mkLaunchdAgent {
          name = "aws-sso-refresh";
          interval = 1800;
        };
      }
    )
  ];
}
