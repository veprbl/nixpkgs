{stdenv, pkgconfig, autoreconfHook, fetchFromGitHub}:

stdenv.mkDerivation rec {
  name = "libspiro-${version}";
  #version = "0.5.20150702";
  version = "0.5.20180226"; # not tagged
  src = fetchFromGitHub {
    owner = "fontforge";
    repo = "libspiro";
    rev = "8c7a31eda7dbd097fd0fae19ca7c7a67bc489d02";
    sha256 = "198v53sl5rwz540zkf8ph037kph74rmshbsjnzaan3fq85dc50c0";
  };

  nativeBuildInputs = [pkgconfig autoreconfHook];

  meta = with stdenv.lib; {
    description = "A library that simplifies the drawing of beautiful curves";
    homepage = https://github.com/fontforge/libspiro;
    license = licenses.gpl3Plus;
  };
}
