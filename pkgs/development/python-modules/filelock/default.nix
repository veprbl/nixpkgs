{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "filelock";
  version = "3.0.10";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d610c1bb404daf85976d7a82eb2ada120f04671007266b708606565dd03b5be6";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/benediktschmitt/py-filelock;
    description = "A platform independent file lock for Python";
    license = licenses.unlicense;
    maintainers = with maintainers; [ hyphon81 ];
  };
}
