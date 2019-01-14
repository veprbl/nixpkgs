{ lib , buildPythonPackage , fetchPypi, colorama, six, mbed-host-tests }:

buildPythonPackage rec {
  pname = "mbed-greentea";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "151whg7z02k17z7p5gd7bf4g9b9px1qi79b1fmbdv9kyjqp8j1h3";
  };

  propagatedBuildInputs = [
    colorama
    mbed-host-tests
    six
  ];

  meta = with lib; {
    description = "mbed 3.0 onwards test suite, codename Greentea. The test suite is a collection of tools that enable automated testing on mbed-enabled platforms";
    homepage = https://github.com/ARMmbed/mbed-os-tools;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
