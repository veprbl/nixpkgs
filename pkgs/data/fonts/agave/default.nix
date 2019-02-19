{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "agave";
  version = "010";

  src = fetchurl {
    url = https://github.com/agarick/agave/releases/download/v010/agave-r.ttf;
    sha256 = "0s8dgs4avlr4y1cgffmmj5m1qfhaaja9yj64y98ismav357x0x1s";
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

