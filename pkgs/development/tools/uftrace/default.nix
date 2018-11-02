{stdenv, fetchFromGitHub, pkgconfig, elfutils, ncurses }:

stdenv.mkDerivation rec {
  name = "uftrace-${version}";
  #version = "0.9";
  version = "2018-10-26";

  src = fetchFromGitHub {
    owner = "namhyung";
    repo = "uftrace";
    rev = "63f73eddfb88e69de6b4b5f4562f91efc4a387dc";
    sha256 = "1nl981md4r8yp08g2qab927q4qczwfranxlvd7zxa0pv994ky0qn";
  };

  postUnpack = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ elfutils ncurses ];

  meta = {
    description = "Function (graph) tracer for user-space";
    homepage = https://github.com/namhyung/uftrace;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = [stdenv.lib.maintainers.nthorne];
  };
}

