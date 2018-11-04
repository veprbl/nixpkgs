{ stdenv, fetchPypi, buildPythonPackage, nose, numpy }:

buildPythonPackage rec {
  pname = "uncertainties";
  version = "3.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "9a98e2d115ce3beacf9e6a33dd10e602b44c16d29a3a43884ec69606c204e0c2";
  };

  buildInputs = [ nose numpy ];

  # No tests included
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://pythonhosted.org/uncertainties/;
    description = "Transparent calculations with uncertainties on the quantities involved (aka error propagation)";
    maintainers = with maintainers; [ rnhmjoj ];
    license = licenses.bsd3;
  };
}
