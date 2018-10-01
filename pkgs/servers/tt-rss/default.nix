{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "tt-rss-${version}";
  version = "2018-08-21";
  rev = "df0115fc7a443669f3326f5abb49eb9754b59263";

  src = fetchurl {
    url = "https://git.tt-rss.org/git/tt-rss/archive/${rev}.tar.gz";
    sha256 = "1ng26z7l51nsvx8fnjpvizmri4xxll4q9d8vp1jx3dqrjsgsz78h";
  };

  installPhase = ''
    mkdir $out
    cp -ra * $out/
  '';

  meta = with stdenv.lib; {
    description = "Web-based news feed (RSS/Atom) aggregator";
    license = licenses.gpl2Plus;
    homepage = https://tt-rss.org;
    maintainers = with maintainers; [ globin zohl ];
    platforms = platforms.all;
  };
}
