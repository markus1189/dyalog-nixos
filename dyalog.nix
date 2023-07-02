{ lib
, stdenv

, fetchurl
, dpkg
, autoPatchelfHook
, makeWrapper

, ncurses5
, glib

, unixODBC

, dotnet-sdk_6
, withDotnet ? true

, R
, rWrapper
, rscproxy
, extraRPackages ? [ ]
, withRConnect ? false

, gtk2
, alsa-lib
, nss_latest
, libXdamage
, libXtst
, libXScrnSaver
, withHTMLRenderer ? false
}:
let
  pname = "dyalog";
  version = "18.2.45405";
  shortVersion = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." version));

  src = fetchurl {
    url = "https://download.dyalog.com/download.php?file=${shortVersion}/linux_64_${version}_unicode.x86_64.deb";
    sha256 = "sha256-pA/WGTA6YvwG4MgqbiPBLKSKPtLGQM7BzK6Bmyz5pmM=";
  };

  wrappedR = rWrapper.override {
    R = R.overrideAttrs (oldAttrs: { nativeBuildInputs = [ autoPatchelfHook ] ++ oldAttrs.nativeBuildInputs; });
    packages = [ rscproxy ] ++ extraRPackages;
  };

in
stdenv.mkDerivation {
  inherit pname version shortVersion src;

  unpackPhase = "dpkg-deb -x $src .";

  nativeBuildInputs = [ autoPatchelfHook makeWrapper dpkg ];

  buildInputs = [
    ncurses5 # Used by the dyalog binary
    glib # Used by Conga and .NET Bridge
    unixODBC # Used by SQAPL
  ]
  ++ lib.optionals withHTMLRenderer [
    gtk2
    alsa-lib
    nss_latest
    libXdamage
    libXtst
    libXScrnSaver
  ];

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
        # needs to be set, as there is no default install location when using Nix
        "--set DOTNET_ROOT ${dotnet-sdk_6}"
      ]
      ++ lib.optional withRConnect
        # dyalog uses the PATH to determine the location of R files
        "--prefix PATH : ${wrappedR}/bin";
    in
    ''
      mkdir -p $out/dyalog $out/bin
      mv opt/mdyalog/${shortVersion}/64/unicode/* $out/dyalog

      cd $out/dyalog

      # File removal is partially based on `https://github.com/Dyalog/DyalogDocker/blob/master/rmfiles.sh`

      # Remove the zero-footprint RIDE
      rm -r RIDEapp

      # Remove workspaces that are not really useful
      rm ws/{apl2in,apl2pcin,ddb,display,eval,fonts,ftp,groups,max,min,ops,quadna,smdemo,smdesign,smtutor,tutor,tube,xfrcode,xlate}.dws

      # Remove other miscellaneous files and directories
      rm -r dwa fonts help Samples scriptbin TestCertificates xfsrc xflib
      rm lib/ademo64.so lib/testcallback.so
      rm aplkeys.sh aplunicd.ini BuildID dyalog.desktop dyalog.rt dyalog.svg languagebar.json magic mapl

      # Patch to use .NET 6.0 instead of .NET Core 3.1 (can be removed when Dyalog 19.0 releases)
      sed -i s/3.1/6.0/g Dyalog.Net.Bridge.{deps,runtimeconfig}.json

      makeWrapper $out/dyalog/dyalog $out/bin/dyalog ${lib.concatStringsSep " " wrapperArgs}
    ''
    + lib.optionalString (!withDotnet) ''
      # Remove .NET files
      rm {libnethost.so,Dyalog.Net.Bridge.*}
    ''
    + lib.optionalString (!withRConnect) ''
      # Remove RConnect workspace
      rm ws/rconnect.dws
    ''
    + lib.optionalString (!withHTMLRenderer) ''
      # Remove HTMLRenderer and CEF files
      rm -r locales swiftshader
      rm lib/htmlrenderer.so libcef.so libEGL.so libGLESv2.so
      rm chrome-sandbox natives_blob.bin snapshot_blob.bin icudtl.dat v8_context_snapshot.bin *.pak 
    '';

  preFixup = lib.optionalString withHTMLRenderer ''
    # `libudev.so` is a runtime dependency of CEF
    patchelf $out/dyalog/libcef.so --add-needed libudev.so
  '';
}
