{ stdenv, fetchurl, python2, makeWrapper }:

stdenv.mkDerivation rec {
  name = "yoda-${version}";
  version = "1.6.3";

  src = fetchurl {
    url = "http://www.hepforge.org/archive/yoda/YODA-${version}.tar.bz2";
    sha256 = "06fsjwgj1cinl23h3mi9kv9fzidbjp9jgqnr27wmz82lzqsf7mqx";
  };

  pythonPath = []; # python wrapper support

  buildInputs = [ python2 makeWrapper ];

  enableParallelBuilding = true;

  postInstall = ''
    for prog in "$out"/bin/*; do
      wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  meta = {
    description = "Provides small set of data analysis (specifically histogramming) classes";
    license     = stdenv.lib.licenses.gpl2;
    homepage    = https://yoda.hepforge.org;
  };
}
