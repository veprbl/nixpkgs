{ stdenv, fetchurl, boost, fastjet, gfortran, gsl, lhapdf, thepeg, zlib }:

stdenv.mkDerivation rec {
  name = "herwig-${version}";
  version = "7.0.2";

  src = fetchurl {
    url = "http://www.hepforge.org/archive/herwig/Herwig-${version}.tar.bz2";
    sha256 = "0phs97swfjlchg2vma8461cwyw3d07igvzzfl6nks7gyx52rf4sq";
  };

  buildInputs = [ boost fastjet gfortran gsl thepeg zlib ]
    # There is a bug that requires for MMHT PDF's to be presend during the build
    ++ (with lhapdf.pdf_sets; [ MMHT2014lo68cl MMHT2014nlo68cl ]);

  configureFlags = [
    "--with-thepeg=${thepeg}"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "A multi-purpose particle physics event generator";
    license     = stdenv.lib.licenses.gpl2;
    homepage    = https://herwig.hepforge.org/;
  };
}
