{ stdenv, buildPythonPackage, fetchPypi, py, pytest }:

buildPythonPackage rec {
  pname = "pytest-datafiles";
  version = "2.0";
  src = fetchPypi {
    inherit version pname;
    sha256 = "143329cbb1dbbb07af24f88fa4668e2f59ce233696cf12c49fd1c98d1756dbf9";
  };

  buildInputs = [ py pytest ];

  meta = with stdenv.lib; {
    license = licenses.mit;
    homepage = https://pypi.python.org/pypi/pytest-catchlog/;
    description = "py.test plugin to create a 'tmpdir' containing predefined files/directories.";
  };
}
