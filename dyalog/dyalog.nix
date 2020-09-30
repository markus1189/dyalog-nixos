{stdenv, xorg, glibc, libiodbc, dpkg, makeWrapper, ncurses5, fetchurl}:

let
  dyalogLibPath = stdenv.lib.makeLibraryPath (with xorg; [
    stdenv.cc.cc.lib
    glibc
    libiodbc
    ncurses5
  ]);
in
stdenv.mkDerivation rec {
  src = fetchurl {
    url = "https://www.dyalog.com/uploads/php/download.dyalog.com/download.php?file=${shortVersion}/linux_64_${version}_unicode.x86_64.deb";
      sha256 = "1i58yc229rqba9rgjqn9i09mf8kn32qhds0x2z3f9vpjzfj7a936";
  };

  name = "dyalog-${version}";

  version = "18.0.38756";

  shortVersion = stdenv.lib.concatStringsSep "." (stdenv.lib.take 2 (stdenv.lib.splitString "." version));

  nativeBuildInputs = [ dpkg ];

  buildInputs = [ makeWrapper ];

  unpackPhase = "dpkg-deb -x $src .";

  installPhase = ''
      mkdir -p $out/ $out/bin
      mv opt/mdyalog/${shortVersion}/64/unicode/* $out/

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
