# Dyalog APL and RIDE Editor

This repository contains two `*.nix` files to install dyalog APL (https://www.dyalog.com/) and RIDE (https://github.com/Dyalog/ride) under NixOS.

## Building dyalog APL:

1. Request your download: https://my.dyalog.com/#DownloadDyalog
2. Download the `*.deb` file and put it into the same directory as `dyalog.nix`
3. Change into the `dyalog` dir and run `nix-build`
4. Run `env RIDE_INIT="SERVE:0.0.0.0:4502" ./result/bin/dyalog +s -q`

You can also pass the path of the `*.deb` source to the `nix-build` of dyalog.nix as an argument.

## Building RIDE:

1. Change into the `ride` dir and run `nix-build`
2. Run `./result/bin/ride`
3. There are two alternatives:
  a. Connect to remote session, which should run on the default port
  b. Use `Start` and specify the full path to the `dyalog/result/bin/dyalog` executable

## Links:

You can find documentation on `dyalog` and `ride` here: https://www.dyalog.com/documentation_170.htm

## And the most important thing

Happy Hacking!