{ stdenv, fetchgit, autoreconfHook, pkgconfig }:

stdenv.mkDerivation {
  pname = "ell";
  version = "2019-03-21";

  src = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     rev = "cc3f62b13d03e9256197cb418401a4552f023c96";
     sha256 = "0wnwqr2r10dzd31xbyi8xnpmxdc8x36vg4pc6xjnh6imz1gmg0vc";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  meta = with stdenv.lib; {
    homepage = https://git.kernel.org/pub/scm/libs/ell/ell.git;
    description = "Embedded Linux Library";
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mic92 dtzWill ];
  };
}
