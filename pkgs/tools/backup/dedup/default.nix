{ stdenv, fetchurl, fetchgit, lz4, snappy, libsodium
# For testing
, coreutils, gawk
}:

stdenv.mkDerivation rec {
  pname = "dedup";
  #version = "1.0";
  version = "2019-05-06";

  #src = fetchurl {
  #  url = "https://dl.2f30.org/releases/${pname}-${version}.tar.gz";
  #  sha256 = "0wd4cnzhqk8l7byp1y16slma6r3i1qglwicwmxirhwdy1m7j5ijy";
  #};
  src = fetchgit {
    url =  git://git.2f30.org/dedup.git;
    rev = "a7753b65b2b40ba265e30e8f2f0bda25da7baa53";
    sha256 = "0g5k32m4h9c0q3z4lqnckcrw9m0gvnm6ih1628xygk2gw7nwr9zk";
  };

  makeFlags = [
    "CC:=$(CC)"
    "PREFIX=${placeholder "out"}"
    "MANPREFIX=${placeholder "out"}/share/man"
  ];

  buildInputs = [ lz4 snappy libsodium ];

  doCheck = true;

  checkInputs = [ coreutils gawk ];
  checkTarget = "test";

  meta = with stdenv.lib; {
    description = "data deduplication program";
    homepage = https://git.2f30.org/dedup/file/README.html;
    license = with licenses; [ bsd0 isc ];
    maintainers = with maintainers; [ dtzWill ];
  };
}
