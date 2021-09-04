self: super:

{
  dyalog = super.callPackage ./dyalog.nix {};
  ride = super.callPackage ./ride.nix {};
}
