{ stdenv, fetchurl, boost, python }:

stdenv.mkDerivation rec {
  name = "lhapdf-${version}";
  version = "6.1.6";

  src = fetchurl {
    url = "http://www.hepforge.org/archive/lhapdf/LHAPDF-${version}.tar.gz";
    sha256 = "1sgbaxv8clcfy4d96fkwfyqcd4b29i0hwv32ry4vy69j5qiki0f2";
  };

  buildInputs = [ boost python ];

  patches = [ ./distutils-c++.patch ];

  configureFlags = "--with-boost=${boost.dev}";

  enableParallelBuilding = true;

  meta = {
    description = "A general purpose interpolator, used for evaluating Parton Distribution Functions from discretised data files";
    license     = stdenv.lib.licenses.gpl2;
    homepage    = http://lhapdf.hepforge.org;
  };
}
