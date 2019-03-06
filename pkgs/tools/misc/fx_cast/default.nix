{ stdenv, fetchurl, dpkg }:

  #json = {
  #  name = "fx_cast_bridge";
  #  description = "";
  #  type = "stdio";
  #  allowed_extensions = [ "fx_cast@matt.tf" ];
  #  path = "";
  #};

stdenv.mkDerivation rec {
  pname = "fx_cast_bridge";
  version = "0.0.2";

  src = fetchurl {
     url = "https://github.com/hensm/fx_cast/releases/download/v${version}/fx_cast_bridge-${version}-x64.deb";
     sha256 = "0kcc7hn3qcnmlydrp85fqjil5bqj0g2bfzdxccqxzxz0xwnc0sj3";
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src ./
    runHook postUnpack
  '';

  dontBuild = true;

  installPhase = ''
    install -DT {opt/fx_cast,$out/bin}/bridge
    install -DT {usr,$out}/lib/mozilla/native-messaging-hosts/fx_cast_bridge.json
  '';


}
