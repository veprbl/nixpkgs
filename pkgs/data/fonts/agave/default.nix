{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "agave";
  version = "010";

  src = fetchurl {
    #url = https://github.com/agarick/agave/releases/download/v010/agave-r.ttf;
    url = "https://github.com/agarick/agave/raw/7bfbd2e11d05929c5c2c230ea89bd822800cfae1/dist/agave-r.ttf";
    sha256 = "0dspxdd2c2zrdmgap1l1nadc8m02pygb7v0wsgc3hv6np1llzpvs";
  };

  sourceRoot = ".";

  unpackPhase = ":";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype/
  '';

  meta = with stdenv.lib; {
    description = "truetype monospaced typeface designed for X environments";
    homepage = https://b.agaric.net/page/agave;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}

