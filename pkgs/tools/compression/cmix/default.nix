{ stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "cmix";
  version = "17";

  src = fetchzip {
    url = "http://www.byronknoll.com/${pname}-v${version}.zip";
    sha256 = "0vxykhka4v8smynq3za1x2nmaq662y3p5iadck86z9jvkm72g2hm";
  };

  makeFlags = [ "CC:=$(CXX)" /* "CC=g++", yes */ ];

  NIX_CFLAGS_COMPILE = [ "-O3" /* override -Ofast, so no compat problems */ ];

  installPhase = ''
    install -Dm755 -t $out/bin/ cmix

    install -Dm644 -t $out/share/cmix/dictionary dictionary/*
  '';

  meta = with stdenv.lib; {
    description = "lossless data compression program aimed at optimizing compression ratio at the cost of high CPU/memory usage";
    homepage = http://www.byronknoll.com/cmix.html;
    license = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
  };
}


