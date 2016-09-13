{ stdenv, fetchurl, fastjet, ghostscript, gsl, hepmc, imagemagick, less, python, texlive, yoda, which, makeWrapper }:

stdenv.mkDerivation rec {
  name = "rivet-${version}";
  version = "2.5.0";

  src = fetchurl {
    url = "http://www.hepforge.org/archive/rivet/Rivet-${version}.tar.bz2";
    sha256 = "1bylkdbyshxsnsgh9wjqfxz6y3xdmlxqp05ssrjsy35y2mbz77y5";
  };

  pythonPath = []; # python wrapper support

  patches = [ ./ns_fix.patch ];

  latex = texlive.combine { inherit (texlive)
    scheme-basic
    collection-pstricks
    collection-fontsrecommended
    mathastext
    pgf
    relsize
    sfmath
    xcolor
    xkeyval
    ;};
  buildInputs = [ fastjet ghostscript gsl hepmc imagemagick python latex yoda makeWrapper ];

  preInstall = ''
    substituteInPlace bin/make-plots \
      --replace '"which"' '"${which}/bin/which"' \
      --replace '"latex"' '"${latex}/bin/latex"' \
      --replace '"dvips"' '"${latex}/bin/dvips"' \
      --replace '"ps2pdf"' '"${ghostscript}/bin/ps2pdf"' \
      --replace '"ps2eps"' '"${ghostscript}/bin/ps2eps"' \
      --replace '"kpsewhich"' '"${latex}/bin/kpsewhich"' \
      --replace '"convert"' '"${imagemagick.out}/bin/convert"'
    substituteInPlace bin/rivet \
      --replace '"less"' '"${less}/bin/less"'
    substituteInPlace bin/rivet-buildplugin \
      --replace '"which"' '"${which}/bin/which"' \
      --replace 'mycxx=' 'mycxx=${stdenv.cc}/bin/${if stdenv.cc.isClang then "clang++" else "g++"}  #' \
      --replace 'mycxxflags="' "mycxxflags=\"-std=c++11 $NIX_CFLAGS_COMPILE $NIX_CXXSTDLIB_COMPILE $NIX_CFLAGS_LINK "
    substituteInPlace bin/rivet-mkhtml \
      --replace '"make-plots"' \"$out/bin/make-plots\" \
      --replace '"rivet-cmphistos"' \"$out/bin/rivet-cmphistos\"
  '';

  configureFlags = [
    "--with-fastjet=${fastjet}"
    "--with-hepmc=${hepmc}"
    "--with-yoda=${yoda}"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    for prog in "$out"/bin/*; do
      wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  meta = {
    description = "A framework for comparison of experimental measurements from high-energy particle colliders to theory predictions";
    license     = stdenv.lib.licenses.gpl2;
    homepage    = https://rivet.hepforge.org;
  };
}
