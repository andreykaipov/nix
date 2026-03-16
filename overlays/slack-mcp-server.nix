{ inputs, ... }:
final: prev: {
  slack-mcp-server = prev.buildGoModule rec {
    pname = "slack-mcp-server";
    version = "1.2.3";

    src = prev.fetchFromGitHub {
      owner = "korotovsky";
      repo = "slack-mcp-server";
      rev = "v${version}";
      hash = "sha256-AfmuQfV3RqFBw9b8B4aFM0EOuFQrUlUpTnMmQcyvCfU=";
    };

    vendorHash = "sha256-mR+UFQRi98OTCyNISy3e7QTGKusd8XhNW4iz57QvpZE=";

    patches = [
      ./slack-mcp-server-skip-cache.patch
    ];

    subPackages = [ "cmd/slack-mcp-server" ];

    ldflags = let pkg = "github.com/korotovsky/slack-mcp-server/pkg/version"; in [
      "-s"
      "-w"
      "-X" "${pkg}.Version=${version}+patched"
    ];
  };
}
