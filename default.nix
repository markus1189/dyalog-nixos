{ pkgs ? import <nixpkgs> {}}:

{
  dyalog = pkgs.callPackage ./dyalog.nix {};
  ride = pkgs.callPackage ./ride.nix {};
}
