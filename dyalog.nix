{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, glib
, ncurses5
, unixODBC
}:

stdenv.mkDerivation rec {
  src = fetchurl {
    url = "https://download.dyalog.com/download.php?file=${shortVersion}/linux_64_${version}_unicode.x86_64.deb";
    sha256 = "sha256-pA/WGTA6YvwG4MgqbiPBLKSKPtLGQM7BzK6Bmyz5pmM=";
  };

  name = "dyalog-${version}";
  version = "18.2.45405";

  shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

  nativeBuildInputs = [ autoPatchelfHook makeWrapper dpkg ];

  buildInputs = [
    glib
    ncurses5
    unixODBC
  ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
    mkdir -p $out/dyalog $out/bin
    mv opt/mdyalog/${shortVersion}/64/unicode/* $out/dyalog

    cd $out/dyalog

    # Remove the pre-packaged RIDE build and everything that uses CEF
    rm -r {RIDEapp,swiftshader,locales}
    rm {lib/htmlrenderer.so,libcef.so,libEGL.so,libGLESv2.so,chrome-sandbox,*.pak,v8_context_snapshot.bin,snapshot_blob.bin,natives_blob.bin}

    # Remove files for .NET support (according to nixpkgs .NET Core 3.1 is EOL and no longer can be installed)
    rm {libnethost.so,Dyalog.Net.*}

    # Remove other miscellaneous files and directories
    rm -r {xfsrc,help,scriptbin,fonts}
    rm {icudtl.dat,magic,dyalog.desktop,mapl,aplkeys.sh,aplunicd.ini,languagebar.json}

    # using flags instead of environment variables ensures that running dyalog with the -script flag works as expected
    # set a compatible TERM variable, otherwise redrawing is broken
    makeWrapper $out/dyalog/dyalog $out/bin/dyalog \
        --set TERM xterm \
        --add-flags DYALOG=$out/dyalog \
        --add-flags SESSION_FILE=$out/dyalog/default.dse
  '';
}
