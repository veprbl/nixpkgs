{ lib
, buildPythonPackage
, fetchPypi
, selenium
, flask
, coverage
}:

buildPythonPackage rec {
  pname = "splinter";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "08c6ed2209ce0520c2f898ad30822ba8f52ed9226bda10c0253c5ea9fe418146";
  };

  propagatedBuildInputs = [ selenium ];

  checkInputs = [ flask coverage ];

  # No tests included
  doCheck = false;

  meta = {
    description = "Browser abstraction for web acceptance testing";
    homepage = https://github.com/cobrateam/splinter;
    license = lib.licenses.bsd3;
  };
}
