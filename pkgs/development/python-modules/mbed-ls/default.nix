{ lib , buildPythonPackage , fetchPypi, appdirs, fasteners, prettytable }:

buildPythonPackage rec {
  pname = "mbed-ls";
  version = "1.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0nyb3cw4851cs8201q2fkna0z565j7169vj7wm2c88c8fm6qd21i";
  };

  propagatedBuildInputs = [
    appdirs
    fasteners
    prettytable
  ];

  doCheck = false; # tests fail

  meta = with lib; {
    description = "mbed-ls is a Python module that detects and lists mbed-enabled devices connected to the host computer";
    homepage = https://github.com/ARMmbed/mbed-os-tools;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
