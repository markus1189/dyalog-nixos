# Dyalog APL and RIDE Editor

This repository contains a `nix` definition to install dyalog APL
(https://www.dyalog.com/) and RIDE (https://github.com/Dyalog/ride).

## Howto

Run `nix-shell` in the directory, providing you with both `dyalog` and
`ride` in your path.  Afterwards you can open RIDE and tell it to
launch `dyalog` (available in PATH).

## Troubleshooting

If you get 404 for dyalog or ride download:
  - dyalog: find new version at https://www.dyalog.com/download-zone.htm
  - ride: find new version at  https://github.com/Dyalog/ride/releases

and update the corresponding files.

## Using the overlay

You can also use the `overlay.nix` file to add `dyalog` and `ride` to
your available packages.  See
https://nixos.org/nixpkgs/manual/#chap-overlays for information on how
to include it.

## Links:

You can find documentation on `dyalog` and `ride` here: https://www.dyalog.com/documentation_180.htm

## And the most important thing

Happy Hacking!
