{ lib
, fetchPypi
, buildPythonPackage
, pythonOlder
}:

buildPythonPackage rec {
  pname = "websockets";
  version = "7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "08e3c3e0535befa4f0c4443824496c03ecc25062debbcf895874f8a0b4c97c9f";
  };

  disabled = pythonOlder "3.3";
  doCheck = false; # protocol tests fail

  meta = {
    description = "WebSocket implementation in Python 3";
    homepage = https://github.com/aaugustin/websockets;
    license = lib.licenses.bsd3;
  };
}
