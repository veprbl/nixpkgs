{ stdenv, fetchurl, dpkg, autoPatchelfHook }:

  #json = {
  #  name = "fx_cast_bridge";
  #  description = "";
  #  type = "stdio";
  #  allowed_extensions = [ "fx_cast@matt.tf" ];
  #  path = "";
  #};

stdenv.mkDerivation rec {
  pname = "fx_cast_bridge";
  version = "0.0.3";

  src = fetchurl {
     url = "https://github.com/hensm/fx_cast/releases/download/v${version}/fx_cast_bridge-${version}-x64.deb";
     sha256 = "0wqm0spmffn31yd23ych6fjxhzfxhj92379h0qdjh2xr3as4yh4n";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib stdenv.cc.libc_lib ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src ./
    runHook postUnpack
  '';

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    install -DT {opt/fx_cast,$out/bin}/bridge
    install -DT {usr,$out}/lib/mozilla/native-messaging-hosts/fx_cast_bridge.json

    substituteInPlace $out/lib/mozilla/native-messaging-hosts/fx_cast_bridge.json \
      --replace /opt/fx_cast/bridge $out/bin/bridge
  '';


}
