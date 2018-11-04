{ lib
, buildPythonPackage
, fetchPypi
, setuptools_scm
, pytest
}:

buildPythonPackage rec {
  pname = "pytest-repeat";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "637e68dd615e850b47b2dee0edf72bcede44de6a5335837fe2980daaf0cdab2b";
  };

  buildInputs = [ setuptools_scm pytest ];

  checkPhase = ''
    py.test
  '';

  meta = {
    description = "Pytest plugin for repeating tests";
    homepage = https://github.com/pytest-dev/pytest-repeat;
    maintainers = with lib.maintainers; [ costrouc ];
    license = lib.licenses.mpl20;
  };
}
