{ lib
, fetchPypi
, buildPythonPackage
, nose
, six
, numpy
, scipy # optional, allows spline-related features (see patsy's docs)
, parameterized
}:

buildPythonPackage rec {
  pname = "patsy";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f115cec4201e1465cd58b9866b0b0e7b941caafec129869057405bfe5b5e3991";
  };

  checkInputs = [ nose parameterized ];
  checkPhase = "nosetests -v";

  propagatedBuildInputs = [
    six
    numpy
    scipy
  ];

  meta = {
    description = "A Python package for describing statistical models";
    homepage = https://github.com/pydata/patsy;
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ilya-kolpakov ];
  };
}

