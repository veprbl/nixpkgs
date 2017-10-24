{ stdenv, fetchhg, autoreconfHook, python2Packages, root, zlib, makeWrapper, withRootSupport ? false }:

let
  cython25 = python2Packages.cython.overrideAttrs (_: rec {
    pname = "Cython";
    version = "0.25.2";

    src = python2Packages.fetchPypi {
      inherit pname version;
      sha256 = "01h3lrf6d98j07iakifi81qjszh6faa37ibx7ylva1vsqbwx2hgi";
    };
  });
in
stdenv.mkDerivation rec {
  name = "yoda-${version}";
  version = "791a95f4453e";

  src = fetchhg {
    url = "https://yoda.hepforge.org/hg/yoda";
    rev = version;
    sha256 = "1adwl973i4k1nyji8rllvwbdd9vkizm7rwsgg8jqp45lpw0qwy3j";
  };

  patches = [
    ./zlib.patch
    ./root2yoda.patch
  ];

  pythonPath = []; # python wrapper support

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = with python2Packages; [ cython25 python makeWrapper zlib ]
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
