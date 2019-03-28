{ stdenv, fetchgit, autoreconfHook, pkgconfig }:

stdenv.mkDerivation {
  pname = "ell";
  version = "2019-03-28";

  src = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     rev = "ad8437eee5d9f0826724aebbd084407f4d4c9a3e";
     sha256 = "1vv60df82f6v9qd8ai8bqhfd6s6b8948lr8nrs9qg9p3nhcxkd37";
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
