{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05-small;
  inputs.ride.url = github:Dyalog/ride;
  inputs.ride.flake = false;

  outputs = { self, nixpkgs, ride }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      ride-src = ride;
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in
    {
      packages.${system} = rec {
        dyalog = pkgs.callPackage ./dyalog.nix { };
        ride = pkgs.callPackage ./ride.nix { src = ride-src; rev = lock.nodes.ride.locked.rev; };

        default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [ dyalog ride ]; };
      };
    };
}
