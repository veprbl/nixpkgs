{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "agave";
  version = "0010a";

  src = fetchurl {
    url = https://github.com/agarick/agave/raw/296fceb7964185c940c48d414f2cbf1b1ab58320/dist/agave-r.ttf;
    sha256 = "0rb7d44xx8yl12b38lc59aynd974bqndnwpzxlx7vi9h2d96l63q";
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

