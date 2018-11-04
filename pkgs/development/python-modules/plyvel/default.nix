{ stdenv
, buildPythonPackage
, fetchPypi
, pkgs
, pytest
, isPy3k
}:

buildPythonPackage rec {
  pname = "plyvel";
  version = "1.0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d64d99fa457fbddb610516f109bd348da143f81324493a14dcb5231db06f8b91";
  };

  buildInputs = [ pkgs.leveldb ] ++ stdenv.lib.optional isPy3k pytest;

  # no tests for python2
  doCheck = isPy3k;

  meta = with stdenv.lib; {
    description = "Fast and feature-rich Python interface to LevelDB";
    homepage = https://github.com/wbolster/plyvel;
    license = licenses.bsd3;
  };

}
