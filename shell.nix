with import <nixpkgs> {};

mkShell {
  buildInputs = [
    (callPackage ./dyalog.nix {})
    (callPackage ./ride.nix {})
  ];
}
