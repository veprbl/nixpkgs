{ stdenv, fetchFromGitHub, cmake, pkgconfig, ncurses }:

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "cmatrix";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "abishekvashok";
    repo = pname;
    rev = "v${version}";
    sha256 = "1h9jz4m4s5l8c3figaq46ja0km1gimrkfxm4dg7mf4s84icmasbm";
  };

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ ncurses ];

  meta = {
    description = "Simulates the falling characters theme from The Matrix movie";
    longDescription = ''
      CMatrix simulates the display from "The Matrix" and is based
      on the screensaver from the movie's website.  
    '';
    homepage = https://github.com/abishekvashok/cmatrix;
    platforms = ncurses.meta.platforms;
    maintainers = [ maintainers.AndersonTorres ];
  };
}
