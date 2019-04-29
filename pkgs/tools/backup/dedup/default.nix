{ stdenv, fetchurl, fetchgit, lz4, snappy, openmp
# For testing
, coreutils, gawk
}:

stdenv.mkDerivation rec {
  pname = "dedup";
  #version = "1.0";
  version = "2019-04-27";

  #src = fetchurl {
  #  url = "https://dl.2f30.org/releases/${pname}-${version}.tar.gz";
  #  sha256 = "0wd4cnzhqk8l7byp1y16slma6r3i1qglwicwmxirhwdy1m7j5ijy";
  #};
  src = fetchgit {
    url =  git://git.2f30.org/dedup.git;
    rev = "9bafc67e4949776e6cf750585244b54dfbeae09c";
    sha256 = "0virw737634pi14pcq5rvxw6zbwkx0nihs9n417p6ain4w7hmf9z";
  };

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=${placeholder "out"}"
    "MANPREFIX=${placeholder "out"}/share/man"
    # These are likely wrong on some platforms, please report!
    "OPENMPCFLAGS=-fopenmp"
    "OPENMPLDLIBS=-lgomp"
  ];

  buildInputs = [ lz4 snappy openmp ];

  doCheck = true;

  checkInputs = [ coreutils gawk ];
  checkPhase = "sh dotest";

  meta = with stdenv.lib; {
    description = "data deduplication program";
    homepage = https://git.2f30.org/dedup/file/README.html;
    license = with licenses; [ bsd0 isc ];
    maintainers = with maintainers; [ dtzWill ];
  };
}
