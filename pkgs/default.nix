{ pkgs, system }:

{
  paperless-gpt = pkgs.callPackage ./paperless-gpt.nix { };
}
