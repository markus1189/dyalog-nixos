self: super:

{
  dyalog = self.callPackage ./dyalog.nix {};
  ride = self.callPackage ./ride.nix {};
}
