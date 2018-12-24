{ pkgs ? import <nixpkgs> {}
, src ? ./linux_64_17.0.34941_unicode.x86_64.deb
}: with pkgs;

let
  dyalogLibPath = stdenv.lib.makeLibraryPath (with pkgs.xorg; [
    stdenv.cc.cc.lib
    glibc
    libiodbc
  ]);
in
  stdenv.mkDerivation rec {
    inherit src;

    name = "dyalog-${version}";

    version = "17.0";

    patch = "34941";

    nativeBuildInputs = [ dpkg ];

    buildInputs = [ makeWrapper ];

    unpackPhase = "dpkg-deb -x $src .";

    installPhase = ''
      mkdir -p $out/ $out/bin
      mv opt/mdyalog/${version}/64/unicode/* $out/

      # Fix for 'lib/cxdya63u64u.so' which for some reason needs .1 instead of packaged .2
      ln -s $out/lib/libodbcinst.so.2 $out/lib/libodbcinst.so.1
      ln -s $out/lib/libodbc.so.2 $out/lib/libodbc.so.1
    '';

    preFixup = ''
      for lib in $out/lib/*.so; do
        patchelf --set-rpath "$out/lib:${dyalogLibPath}" \
                 $lib
      done

      find $out/ -executable -not -name "*.so*" -type f | while read bin; do
        patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
                 --set-rpath "$out/lib:${dyalogLibPath}" \
                 $bin || true
      done

      # set a compatible TERM variable, otherwise redrawing is broken
      wrapProgram $out/dyalog \
                  --set TERM xterm \
                  --set SESSION_FILE $out/default.dse

      ln -s $out/dyalog $out/bin/dyalog
    '';
  }
