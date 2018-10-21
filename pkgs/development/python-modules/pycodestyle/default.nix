{ lib, buildPythonPackage, fetchFromGitHub }:

buildPythonPackage rec {
  pname = "pycodestyle";
  version = "2018-09-06";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = pname;
    rev = "c3d2cbd744236c3a41d1013c9dce2712dcc4eee0";
    sha256 = "1mryh898spzh407cyj1azdz2gls17g1x1m7fv6bfdcm2kxj7zm2y";
  };

  meta = with lib; {
    description = "Python style guide checker (formerly called pep8)";
    homepage = https://pycodestyle.readthedocs.io;
    license = licenses.mit;
    maintainers = with maintainers; [ garbas ];
  };
}
