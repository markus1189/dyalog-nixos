{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./ride.nix {}
