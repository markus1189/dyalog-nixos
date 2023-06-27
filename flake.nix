{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05-small;
  inputs.ride.url = github:Dyalog/ride;
  inputs.ride.flake = false;
  inputs.rscproxy.url = github:Dyalog/rscproxy;
  inputs.rscproxy.flake = false;

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };

      lock = builtins.fromJSON (builtins.readFile ./flake.lock);

      rscproxy = pkgs.rPackages.buildRPackage { name = "rscproxy"; src = inputs.rscproxy; };

      dyalog = pkgs.callPackage ./dyalog.nix { inherit rscproxy; };
      ride = pkgs.callPackage ./ride.nix { src = inputs.ride; rev = lock.nodes.ride.locked.rev; };
    in
    {
      packages.${system} = {
        inherit dyalog ride;
        default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [ dyalog ride ]; };
      };
    };
}
