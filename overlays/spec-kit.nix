{ inputs, ... }:

final: prev: {
  spec-kit = prev.spec-kit.overrideAttrs (old: {
    version = "0.2.0";
    src = prev.fetchFromGitHub {
      owner = "github";
      repo = "spec-kit";
      tag = "v0.2.0";
      hash = "sha256-O1q+K8AP6Gd8ONYVfoTIY8YKfKtIVGAMKVv89k0xO5A=";
    };
    propagatedBuildInputs =
      (old.propagatedBuildInputs or [ ])
      ++ (with prev.python3Packages; [
        pyyaml
        packaging
      ]);
  });
}
