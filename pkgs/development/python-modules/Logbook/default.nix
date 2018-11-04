{ lib, buildPythonPackage, fetchPypi, isPy3k, pytest, mock, brotli }:

buildPythonPackage rec {
  pname = "Logbook";
  version = "1.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "32375ce706d04a46886f9818bb953e53e0eda636552d7c0a2e482dd670fa56db";
  };

  checkInputs = [ pytest ] ++ lib.optionals (!isPy3k) [ mock ];

  propagatedBuildInputs = [ brotli ];

  checkPhase = ''
    find tests -name \*.pyc -delete
    py.test tests
  '';

  meta = {
    homepage = https://pythonhosted.org/Logbook/;
    description = "A logging replacement for Python";
    license = lib.licenses.bsd3;
  };
}
