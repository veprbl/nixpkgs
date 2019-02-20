{ lib, buildPythonPackage, fetchFromGitHub, appdirs, fasteners, prettytable, pytest, mock, mbed-os-tools }:

buildPythonPackage rec {
  pname = "mbed-os-tools";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "ARMmbed";
    repo = "mbed-os-tools";
    rev = "v${version}";
    sha256 = "19ssqr5b5lzfvbjlz168ffkj8x764vfqfnk5q3wr17f3nfv6f445";
  };

  checkInputs = [
    mock
    pytest
  ];

  propagatedBuildInputs = [
    appdirs
    fasteners
    prettytable
  ];

  #preCheck = ''
  #  export HOME=$(mktemp -d)

  #  # this test requires test_data, which is not present in Pypi
  #  rm test/platform_detection.py
  #'';

  meta = with lib; {
    description = "A Python module that detects and lists mbed-enabled devices connected to the host computer";
    homepage = https://github.com/ARMmbed/mbed-os-tools;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
