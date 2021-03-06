{ alsaLib
, atk
, cairo
, cups
, dbus_daemon
, dpkg
, electron_6
, expat
, fetchurl
, fetchFromGitHub
, fontconfig
, gdk_pixbuf
, glib
, glibc
, gnome2
, gtk3
, libpthreadstubs
, libxcb
, lib
, makeWrapper
, nspr
, nss
, pango
, runtimeShell
, stdenv
, util-linux
, writeScript
, xorg
}:

let
  libPath = lib.makeLibraryPath (with xorg; [
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
    #!${runtimeShell}
    set -e
    ${electron_6}/bin/electron TODO/resources/app
  '';

  drv = stdenv.mkDerivation rec {
    pname = "ride";
    version = "4.3.3463-1";

    shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

    # deal with '-1' suffix...
    cleanedVersion = builtins.replaceStrings [ "-1" ] [ "" ] version;

    src = fetchurl {
      url = "https://github.com/Dyalog/ride/releases/download/v${cleanedVersion}/ride-${version}_amd64.deb";
      sha256 = "sha256:0rkh7c1m1xflapb510vjv4d1q4sqj63y5mlrhnqxgz1jaqz6aap7";
    };

    nativeBuildInputs = [ dpkg ];

    buildInputs = [ makeWrapper util-linux ];

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
