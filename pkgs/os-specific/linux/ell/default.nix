{ stdenv, fetchgit, autoreconfHook, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "ell";
  # version = "0.18";
  version = "2019-04-05";

  src = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     # rev = "refs/tags/${version}";
     rev = "3874a38c8b9b1cf5fcd4de551f0618a9a50d5577";
     sha256 = "1ff7sbf083flczprsk1kjfjigxjw1sdv11m0snbm8hdbc3j9lmyc";
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
