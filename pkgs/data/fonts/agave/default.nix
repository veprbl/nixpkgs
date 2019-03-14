{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "agave";
  version = "010";

  src = fetchurl {
    #url = https://github.com/agarick/agave/releases/download/v010/agave-r.ttf;
    url = "https://github.com/agarick/agave/raw/7e56343b0b3489d8fbc7e11a2ce92ac199a34e6d/dist/agave-r.ttf";
    sha256 = "19zvhz65a2j098v3457np8hm8fiyfvmpdjrsc28f58y1g3m4ixax";
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

