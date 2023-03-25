{
  inputs.ride.url = github:Dyalog/ride;
  inputs.ride.flake = false;

  outputs = {
    self,
    nixpkgs,
    ride,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = import ./default.nix {inherit pkgs;};
    devShells.${system}.default = import ./shell.nix;
    overlays.default = final: prev: (import ./overlay.nix final prev);
  };
}
