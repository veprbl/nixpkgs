{ stdenv, fetchurl, fetchgit, lz4, snappy, openmp ? null }:

stdenv.mkDerivation rec {
  pname = "dedup";
  #version = "1.0";
  version = "2019-04-18";

  #src = fetchurl {
  #  url = "https://dl.2f30.org/releases/${pname}-${version}.tar.gz";
  #  sha256 = "0wd4cnzhqk8l7byp1y16slma6r3i1qglwicwmxirhwdy1m7j5ijy";
  #};
  src = fetchgit {
    url =  git://git.2f30.org/dedup.git;
    rev = "3d79ba2671de814d94474dce3765be64a982cc5a";
    sha256 = "0fhlxcgc05pjkdmd0ibpzfglsxi2gr1lcrn8qz9ibmrwddznzqck";
  };

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=${placeholder "out"}"
    "MANPREFIX=${placeholder "out"}/share/man"
  ] ++ stdenv.lib.optional (openmp != null) [
    "OPENMPCFLAGS=-fopenmp"
    "OPENMPLDLIBS=-lgomp"
  ];

  buildInputs = [ lz4 snappy openmp ];

  meta = with stdenv.lib; {
    description = "data deduplication program";
    homepage = https://git.2f30.org/dedup/file/README.html;
    license = with licenses; [ bsd0 isc ];
    maintainers = with maintainers; [ dtzWill ];
  };
}
