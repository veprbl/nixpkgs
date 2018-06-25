{ stdenv, buildPythonPackage, fetchPypi, isPyPy }:

buildPythonPackage rec {
  name = "${pname}-${version}";
  pname = "cachetools";
  version = "1.1.6";
  disabled = isPyPy;  # a test fails

  src = fetchPypi {
    inherit pname version;
    sha256 = "d1a44ffd2eedd138f3ba69038feb807ea54cb24e8a207a52d3a8603bc4961821";
  };

  meta = with stdenv.lib; {
    homepage = "https://github.com/tkem/cachetools";
    license = licenses.mit;
  };
}
