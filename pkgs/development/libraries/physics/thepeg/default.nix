{ stdenv, fetchurl, boost, fastjet, gsl, hepmc, lhapdf, rivet, zlib }:

stdenv.mkDerivation rec {
  name = "thepeg-${version}";
  version = "2.0.2";

  src = fetchurl {
    url = "http://www.hepforge.org/archive/thepeg/ThePEG-${version}.tar.bz2";
    sha256 = "16vqjihyv0bphdihl83p65rxkgdhvwp2sa9k0x9cgma3jl0rw96l";
  };

  buildInputs = [ boost fastjet gsl hepmc lhapdf rivet zlib ]
    # There is a bug that requires for MMHT PDF's to be presend during the build
    ++ (with lhapdf.pdf_sets; [ MMHT2014lo68cl MMHT2014nlo68cl ]);

  configureFlags = [
    "--with-hepmc=${hepmc}"
    "--without-javagui"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Toolkit for High Energy Physics Event Generation";
    license     = stdenv.lib.licenses.gpl2;
    homepage    = https://herwig.hepforge.org/;
  };
}
