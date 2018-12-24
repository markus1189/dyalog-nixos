{ pkgs ? import <nixpkgs> {}}: with pkgs;

let
  libPath = stdenv.lib.makeLibraryPath (with pkgs.xorg; [
    alsaLib
    atk
    cairo
    cups
    dbus_daemon.lib
    expat
    fontconfig
    gdk_pixbuf
    glib
    glibc
    gnome2.GConf
    pango
    gtk3
    libpthreadstubs
    libxcb
    nspr
    nss
    stdenv.cc.cc.lib

    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXScrnSaver
    libXtst
  ]);
  electronLauncher = writeScript "rideWrapper" ''
    #!${pkgs.runtimeShell}
    set -e
    ${pkgs.electron}/bin/electron TODO/resources/app
  '';
  drv = stdenv.mkDerivation rec {
    name = "ride-${version}";

    version = "4.1.3366";

    shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

    src = fetchurl {
      url = "https://github.com/Dyalog/ride/releases/download/v${version}/ride-${version}_linux.amd64.deb";
      sha256 = "13a1z3wggkcmqin2ia4zf37gmyjc4val68g50f7lxacvv8v8jv9w";
    };

    nativeBuildInputs = [ dpkg ];

    buildInputs = [ makeWrapper ];

    unpackPhase = "dpkg-deb -x $src .";

    installPhase = ''
      mkdir -p $out/
      mv opt/ride-${shortVersion}/* $out/

      mkdir $out/bin
      cp ${electronLauncher} $out/bin/ride
      sed -i -e "s|TODO|$out|" $out/bin/ride
    '';

    preFixup = ''
      for lib in $out/*.so; do
        patchelf --set-rpath "${libPath}" $lib
      done

      for bin in $out/Ride-${shortVersion}; do
        patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
                 --set-rpath "$out:${libPath}" \
                 $bin
      done
    '';
  };
in
  drv
