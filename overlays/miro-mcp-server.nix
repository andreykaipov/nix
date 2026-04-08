{ inputs, ... }:
final: prev: {
  miro-mcp-server = prev.buildGoModule rec {
    pname = "miro-mcp-server";
    version = "1.16.2";

    src = prev.fetchFromGitHub {
      owner = "olgasafonova";
      repo = "miro-mcp-server";
      rev = "v${version}";
      hash = "sha256-qnJgOdnKtNvOYYdh2wiw9kjiITlWZPgFWYgTsv8/CYc=";
    };

    vendorHash = "sha256-+NaxFSjO8PQ/6pPc48h+xzl1rzRYLRRBzUWGDp1qAl8=";

    subPackages = [ "." ];

    ldflags = [
      "-s"
      "-w"
    ];
  };
}
