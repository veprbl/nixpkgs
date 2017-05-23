{ stdenv, fetchhg, autoreconfHook, python2Packages, root, makeWrapper, withRootSupport ? false }:

stdenv.mkDerivation rec {
  name = "yoda-${version}";
  version = "791a95f4453e";

  src = fetchhg {
    url = "https://yoda.hepforge.org/hg/yoda";
    rev = version;
    sha256 = "1adwl973i4k1nyji8rllvwbdd9vkizm7rwsgg8jqp45lpw0qwy3j";
  };

  pythonPath = []; # python wrapper support

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = with python2Packages; [ cython python makeWrapper ]
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
