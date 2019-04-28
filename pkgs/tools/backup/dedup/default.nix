{ stdenv, fetchurl, fetchgit, lz4, snappy, openmp
# For testing
, coreutils, gawk
}:

stdenv.mkDerivation rec {
  pname = "dedup";
  #version = "1.0";
  version = "2019-04-26";

  #src = fetchurl {
  #  url = "https://dl.2f30.org/releases/${pname}-${version}.tar.gz";
  #  sha256 = "0wd4cnzhqk8l7byp1y16slma6r3i1qglwicwmxirhwdy1m7j5ijy";
  #};
  src = fetchgit {
    url =  git://git.2f30.org/dedup.git;
    rev = "74e630b82162820aef9515874dcf5ef06269e9a8";
    sha256 = "05sx4whg46683vvdmdj5nswkxc7lqhpiivsycs985lvngb328yvn";
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
