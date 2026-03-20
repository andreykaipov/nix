{ inputs, ... }:
final: prev: {
  terraform-mcp-server = prev.buildGoModule rec {
    pname = "terraform-mcp-server";
    version = "0.4.0-unstable-2026-03-17";

    src = prev.fetchFromGitHub {
      owner = "surian";
      repo = "terraform-mcp-server";
      rev = "97f0fc0fc0d895be86327ed70e6b5de8295879e8";
      hash = "sha256-1+rG8h89y59QvHMsd6Ar5FBqHyGUW2kS98b4hSKjK74=";
    };

    vendorHash = "sha256-o9KAMSbzJuzH/zrlEGvkl3RXQDiMFoI+7fknR/YBhFk=";

    subPackages = [ "cmd/terraform-mcp-server" ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/hashicorp/terraform-mcp-server/version.fullVersion=${version}"
      "-X github.com/hashicorp/terraform-mcp-server/version.GitCommit=97f0fc0"
      "-X github.com/hashicorp/terraform-mcp-server/version.BuildDate=2026-03-17T00:00:00Z"
    ];
  };
}
