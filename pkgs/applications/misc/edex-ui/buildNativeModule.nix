{ stdenv, fetchurl, fetchNodeModules, python2, nodePackages }:
{ name, src, nodejs, sha256, nodeSHA256, headerVersion, headerSHA256 }:

let
  plat = {
    "i386-linux" = "ia32";
    "x86_64-linux" = "x64";
  }.${stdenv.hostPlatform.system};

  headers = fetchurl {
    url = "https://atom.io/download/electron/v${headerVersion}/iojs-v${headerVersion}.tar.gz";
    sha256 = headerSHA256;
  };
in stdenv.mkDerivation rec {
  inherit src name;

  outputHash = sha256;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  node_modules = fetchNodeModules {
    inherit src nodejs;
    sha256 = nodeSHA256;
  };

  configurePhase = ''
    cp -r ${node_modules} node_modules
  '';

  nativeBuildInputs = [
    nodejs
    python2
    nodePackages.node-gyp
  ];

  buildPhase = ''
    HOME=. node-gyp \
      --arch=${plat} \
      --target=${headerVersion} \
      --tarball=${headers} \
      rebuild
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
