{ lib, buildPythonPackage, fetchFromGitHub,
flake8, future, mock, pytest, pytestcov, pytest-forked, pytest-timeout, pytest_xdist, six
}:

buildPythonPackage rec {
  pname = "httplib2";
  version = "0.12.0.1"; # 0.12.0 + pr111

  # Upstream PR 111, using my fork to ensure commits don't go anywhere
  src = fetchFromGitHub {
    owner = "httplib2";
    repo = "httplib2";
    rev = "d26ed028c0eccdfdc94316eaaf07982d8520ee9e";
    sha256 = "02na5cb3s14lq0wawyzqilg9b13h3ra6dyin04rr5fqvmfsn9hbp";
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
