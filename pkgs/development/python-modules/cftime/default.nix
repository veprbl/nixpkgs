{ buildPythonPackage
, fetchPypi
, pytest
, coveralls
, pytestcov
, cython
, numpy
}:

buildPythonPackage rec {
  pname = "cftime";
  version = "1.0.2.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "2c81d4879a2c1753961d647e55e0125039ddeda195944c3d526f2cf087dfb7bb";
  };

  checkInputs = [ pytest coveralls pytestcov ];
  buildInputs = [ cython ];
  propagatedBuildInputs = [ numpy ];

  checkPhase = ''
    py.test
  '';

  meta = {
    description = "Time-handling functionality from netcdf4-python";
  };

}