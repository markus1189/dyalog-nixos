{
  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      dyalog = pkgs.callPackage ./dyalog.nix {};
      ride = pkgs.callPackage ./ride.nix {};

      default = pkgs.symlinkJoin { name = "dyalog-and-ride"; paths = [dyalog ride]; };
    };
  };
}
