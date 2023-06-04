{ src
, rev
, lib
, fetchFromGitHub
, buildNpmPackage
, makeWrapper
, python3
, electron
}:

let
  pname = "ride";

  packageInfo = builtins.fromJSON (builtins.readFile (src + "/package.json"));

  version = lib.concatStringsSep "." (lib.take 2 (lib.splitString "." packageInfo.version));

  versionJSON = builtins.toJSON {
    versionInfo = {
      inherit version rev;
      date = "unknown (built by Nix)";
    };
  };

in
buildNpmPackage {

  inherit pname version src;

  npmInstallFlags = [ "--omit=dev" ];

  # Skips the auto-downloaded electron binary
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  npmDepsHash = "sha256-mgkOTuspqoM4yZMr2u7f+0qSgzIMz033GXezuPA7rkQ=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper python3 ];

  # This is the replacement for the `mk` script in the source repo
  postInstall = ''
    cd $out/lib/node_modules/${packageInfo.name}

    mkdir $out/app
    cp -r {src,lib,node_modules,D.png,favicon.*,*.html,main.js,package.json} $out/app

    mkdir $out/app/style
    cp -r style/{fonts,img,*.css} $out/app/style

    cd $out/app/node_modules
    rm -r {.bin,monaco-editor/{dev,esm,min-maps}}
    find . -type f -name '*.map' -exec rm -rf {} +
    find . -type d -name 'test' -exec rm -rf {} +

    rm -r $out/lib

    # Generate version-info
    mkdir $out/app/_
    echo 'D=${versionJSON}' > $out/app/_/version.js
    echo ${version} > $out/app/_/version

    # Call electron manually
    makeWrapper ${electron}/bin/electron $out/bin/ride \
            --add-flags $out/app
  '';
}
