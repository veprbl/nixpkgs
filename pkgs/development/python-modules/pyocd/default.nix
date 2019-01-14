{ lib , buildPythonPackage , fetchPypi, setuptools_scm, setuptools_scm_git_archive }:

buildPythonPackage rec {
  pname = "pyocd";
  version = "0.14.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1k6b4hkc8zapid6rcgwmz6c5vkv24ix945j657km9n1k3b14dlrj";
  };

  propagatedBuildInputs = [
    setuptools_scm
    setuptools_scm_git_archive
  ];

  meta = with lib; {
    description = "Open source Python library for programming and debugging Arm Cortex-M microcontrollers using CMSIS-DAP";
    homepage = https://github.com/mbedmicro/pyOCD;
    license = licenses.asl20;
    maintainers = with maintainers; [ rvolosatovs ];
  };
}
