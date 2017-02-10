{ stdenv, fetchurl, cmake, xlibsWrapper, openblas }:

stdenv.mkDerivation rec {
  version = "19.2";
  name = "dlib-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/dclib/dlib/${name}.tar.bz2";
    sha256 = "0jh840b3ynlqsvbpswzg994yk539zbhx2sk6lybd23qyd2b8zgi8";
  };

  enableParallelBuilding = true;
  buildInputs = [ cmake xlibsWrapper openblas ];
  propagatedBuildInputs = [ xlibsWrapper ];

  meta = with stdenv.lib; {
    description = "A general purpose cross-platform C++ machine learning library";
    homepage = http://www.dlib.net;
    license = stdenv.lib.licenses.boost;
    maintainers = with maintainers; [ christopherpoole ];
    platforms = stdenv.lib.platforms.all;
  };
}

