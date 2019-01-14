{ lib , buildPythonPackage , fetchPypi, mbed-ls, future, pyserial, pyocd }:

buildPythonPackage rec {
  pname = "mbed-host-tests";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0n3myjw3jx4a1mhf7nsk7p99h4iw0sj6gwxq9wlmh16v316axaz4";
  };

  propagatedBuildInputs = [
    future
    mbed-ls
    pyserial
    pyocd
  ];

  meta = with lib; {
    description = "mbed tools used to flash, reset and supervise test execution for mbed-enabled devices";
    homepage = https://github.com/ARMmbed/mbed-os-tools;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
