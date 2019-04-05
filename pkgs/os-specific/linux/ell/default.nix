{ stdenv, fetchgit, autoreconfHook, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "ell";
  version = "0.18";

  src = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     rev = "refs/tags/${version}";
     sha256 = "0pjppwxjwbp71c3wmmg65yr9167q05pd697ai88g701bi2slfyiy";
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
