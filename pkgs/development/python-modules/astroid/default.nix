{ lib, fetchFromGitHub, buildPythonPackage, pythonOlder, isPyPy
, lazy-object-proxy, six, wrapt, typing, typed-ast
, pytestrunner, pytest
}:

buildPythonPackage rec {
  pname = "astroid";
  version = "2018-10-01"; #"2.0.4";

  disabled = pythonOlder "3.4";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "astroid";
    rev = "e2fc3c5636544539cad69e25af7de155539558c0";
    sha256 = "09spl7yw3f7i55p2wfvjqj6f09hpd4jijvcng8npgp3zjw42f1s7";
  };

  # From astroid/__pkginfo__.py
  propagatedBuildInputs = [ lazy-object-proxy six wrapt ]
    ++ lib.optional (pythonOlder "3.5") typing
    ++ lib.optional (pythonOlder "3.7" && !isPyPy) typed-ast;

  checkInputs = [ pytestrunner pytest ];

  meta = with lib; {
    description = "An abstract syntax tree for Python with inference support";
    homepage = https://github.com/PyCQA/astroid;
    license = licenses.lgpl2;
    platforms = platforms.all;
    maintainers = with maintainers; [ nand0p ];
  };
}
