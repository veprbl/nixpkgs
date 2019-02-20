{ lib, buildPythonPackage, fetchPypi, appdirs, fasteners, prettytable, pytest, mock, mbed-os-tools }:

buildPythonPackage rec {
  pname = "mbed-ls";
  version = "1.7.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0qlxqkmm7dh6ql99n0gy03zsrsv12akbasxj4lxzsxjw1rvmhn6k";
  };

  propagatedBuildInputs = [
    appdirs
    fasteners
    prettytable
    mbed-os-tools
  ];

  meta = with lib; {
    description = "mbed-ls is a Python module that detects and lists mbed-enabled devices connected to the host computer";
    homepage = https://github.com/ARMmbed/mbed-os-tools;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
