{ stdenv, fetchgit, autoreconfHook, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "ell";
  version = "0.20";
  #version = "2019-04-30";

  src = fetchgit {
     url = https://git.kernel.org/pub/scm/libs/ell/ell.git;
     rev = "refs/tags/${version}";
     #rev = "a84f254a5207142fa81e458d74b4585549d8c172";
     sha256 = "1g143dbc7cfks63k9yi2m8hpgfp9jj5b56s3hyxjzxm9dac3yn6c";
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
