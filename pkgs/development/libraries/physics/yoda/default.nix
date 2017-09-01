{ stdenv, fetchhg, autoreconfHook, python2Packages, root, zlib, makeWrapper, withRootSupport ? false }:

stdenv.mkDerivation rec {
  name = "yoda-${version}";
  version = "3a1c29fcdca6";

  src = fetchhg {
    url = "https://yoda.hepforge.org/hg/yoda";
    rev = version;
    sha256 = "0blymidv0mia59r0cpzl53b23sxm85lhzfd94xn6b54cilvzc9d3";
  };

  pythonPath = []; # python wrapper support

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = with python2Packages; [ cython python makeWrapper zlib ]
    ++ stdenv.lib.optional withRootSupport root;
  propagatedBuildInputs = with python2Packages; [ matplotlib numpy ];

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
    platforms   = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ veprbl ];
  };
}
