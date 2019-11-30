{ pkgs ? import <nixpkgs> {}}:

{
  dyalog = pkgs.callPackage ./dyalog {};
  ride = pkgs.callPackage ./ride {};
}
