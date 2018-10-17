{ lib, buildPythonPackage, fetchFromGitHub,
flake8, future, mock, pytest, pytestcov, pytest-forked, pytest-timeout, pytest_xdist, six
}:

buildPythonPackage rec {
  pname = "httplib2";
  version = "0.11.3-pr111";

  # Upstream PR 111, using my fork to ensure commits don't go anywhere
  src = fetchFromGitHub {
    owner = "dtzWill";
    repo = "httplib2";
    rev = "7ee25dbcc24fbe42d2f7b2839327d58ecf3c8e71";
    sha256 = "0mvqmbv9ccrshcngjdm6yrrd90n5mwa2qcr4nlpkz00ravsarzr9";
  };

  # Eep, avoid test dep we haven't packaged yet :3
  postPatch = ''
    sed -i '/pytest-randomly/d' requirements-test.txt
  '';

  checkInputs = [
    flake8 future mock pytest pytestcov pytest-forked pytest-timeout pytest_xdist six
  ];

  doCheck = false; # network

  meta = with lib; {
    homepage = http://code.google.com/p/httplib2;
    description = "A comprehensive HTTP client library";
    license = licenses.mit;
    maintainers = with maintainers; [ garbas ];
  };
}
