{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper
, glib
, ncurses5
, unixODBC
, dotnet-sdk_6
, withDotnet ? true
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

  installPhase =
    let
      wrapperArgs = [
        # if not set redrawing is broken
        "--set TERM xterm"
        # needs to be set when the `-script` flag is used
        "--add-flags DYALOG=$out/dyalog"
        # needed for default user commands to work
        "--add-flags SESSION_FILE=$out/dyalog/default.dse"
      ]
      ++ lib.optionals withDotnet [
        # .Net Bridge .dll files cannot be hard linked with autoPatchelfHook, but are still runtime dependencies
        "--prefix LD_LIBRARY_PATH : $out/dyalog"
        # needs to be set, as there is no default install location in NixOS
        "--set DOTNET_ROOT ${dotnet-sdk_6}"
      ];

    in
    ''
      mkdir -p $out/dyalog $out/bin
      mv opt/mdyalog/${shortVersion}/64/unicode/* $out/dyalog

      cd $out/dyalog

      # Remove the pre-packaged RIDE build and everything that uses CEF
      rm -r {RIDEapp,swiftshader,locales}
      rm {lib/htmlrenderer.so,libcef.so,libEGL.so,libGLESv2.so,chrome-sandbox,*.pak,v8_context_snapshot.bin,snapshot_blob.bin,natives_blob.bin}

      # Patch to use .NET 6.0 instead of .NET Core 3.1 (can be removed when Dyalog 19.0 releases)
      sed -i s/3.1/6.0/g Dyalog.Net.Bridge.{deps,runtimeconfig}.json
      
      # Remove other miscellaneous files and directories
      rm -r {xfsrc,help,scriptbin,fonts}
      rm {icudtl.dat,magic,dyalog.desktop,mapl,aplkeys.sh,aplunicd.ini,languagebar.json}
 
      makeWrapper $out/dyalog/dyalog $out/bin/dyalog ${lib.concatStringsSep " " wrapperArgs}
    ''
    + lib.optionalString (!withDotnet) ''
      # Remove .NET files
      rm {libnethost.so,Dyalog.Net.Bridge.*}
    '';
}
