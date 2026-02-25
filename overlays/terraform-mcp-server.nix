{ inputs, ... }:
final: prev: {
  terraform-mcp-server = prev.buildGoModule rec {
    pname = "terraform-mcp-server";
    version = "0.4.0-unstable-2026-03-10";

    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = "terraform-mcp-server";
      rev = "fda411065144192e831e852cd6fbeda6f88c6e1e";
      hash = "sha256-Cu8yQj4sCK27/61Bc0m8Wob4/3OBdPecODGWAaC4o/w=";
    };

    vendorHash = "sha256-o9KAMSbzJuzH/zrlEGvkl3RXQDiMFoI+7fknR/YBhFk=";

    subPackages = [ "cmd/terraform-mcp-server" ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/hashicorp/terraform-mcp-server/version.fullVersion=${version}"
      "-X github.com/hashicorp/terraform-mcp-server/version.GitCommit=fda4110"
      "-X github.com/hashicorp/terraform-mcp-server/version.BuildDate=2026-03-10T00:00:00Z"
    ];
  };
}
