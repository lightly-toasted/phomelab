{
  description = "Declarative configuration for my homelab using Ansible";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import (inputs.nixpkgs) { inherit system; });
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            ansible
            just
          ];

          shellHook = ''
            ansible --version
          '';
        };
      }
  );
}
