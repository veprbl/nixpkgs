{ lib, fetchPypi, buildPythonPackage, pythonOlder, attrs }:

buildPythonPackage rec {
  pname = "aiorpcx";
  version = "0.18.0";

  src = fetchPypi {
    inherit version;
    pname = "aiorpcX";
    sha256 = "17sh1y36j84kjshxn6whg86cigcx2i5qd8ygpmg9pa1qsv9b19ck";
  };

  propagatedBuildInputs = [ attrs ];

  disabled = pythonOlder "3.6";

  # Checks needs internet access
  doCheck = false;

  meta = {
    description = "Transport, protocol and framing-independent async RPC client and server implementation";
    license = lib.licenses.mit;
    homepage = https://github.com/kyuupichan/aiorpcX;
  };
}
