{ stdenv
, buildPythonPackage
, fetchPypi
, nose
, six
, pytest
, pytestrunner
}:

buildPythonPackage rec {
  pname = "Paste";
  version = "3.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "01w26w9jyfkh0mfydhfz3dwy3pj3fw7mzvj0lna3vs8hyx1hwl0n";
  };

  checkInputs = [ nose pytest pytestrunner ];
  propagatedBuildInputs = [ six pytestrunner ];

  # TODO: enable this by selectively disabling network tests
  doCheck = false;

  # Certain tests require network
  checkPhase = ''
    NOSE_EXCLUDE=test_ok,test_form,test_error,test_stderr,test_paste_website nosetests
  '';

  meta = with stdenv.lib; {
    description = "Tools for using a Web Server Gateway Interface stack";
    homepage = http://pythonpaste.org/;
    license = licenses.mit;
  };

}
