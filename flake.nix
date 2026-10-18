{
  description = "Run your homelab on phones";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-versions.url = "github:denful/nix-versions";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      
      perSystem = { pkgs, system, ... }: {
        packages = import ./pkgs {
          inherit pkgs system;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            ansible
            ansible-lint
            just
            zensical
            inputs.nix-versions.packages.${system}.default
          ];

          shellHook = ''
            ansible --version
          '';
        };
      };
    };
}
