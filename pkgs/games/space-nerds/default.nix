{ stdenv, fetchFromGitHub, pkgconfig, portaudio, libvorbis, lua5, libpng, SDL
, glew, gtkglext, gtk2, pangox_compat, libXmu, openscad }:

stdenv.mkDerivation {
  name = "space-nerds-git";

  src = fetchFromGitHub {
    owner = "smcameron";
    repo = "space-nerds-in-space";
    rev = "782c624d99c"; # master today
    sha256 = "1iqzhm4aa97lj59dnjlnckzhgjv2g7wg3vqpv86sidgzcqbvndkb";
  };

  postPatch = ''
    substituteInPlace Makefile --replace 'DESTDIR=.' 'DESTDIR?=.'
    sed '/pkg-config/s/lua5\.2/lua/' -i Makefile
  '';

  buildInputs = [
    pkgconfig portaudio libvorbis lua5 libpng SDL
    glew gtkglext gtk2 pangox_compat libXmu openscad
  ];

  enableParallelBuilding = true;

  makeFlags = [ "PREFIX=$(out)" "DESTDIR=/" ];

}

