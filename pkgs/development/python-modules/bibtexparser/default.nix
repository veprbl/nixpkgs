{ lib
, buildPythonPackage, fetchFromGitHub
, future, pyparsing
, glibcLocales, nose, unittest2
}:

buildPythonPackage rec {
  pname = "bibtexparser";
  #version = "1.0.1";
  version = "2018-10-06";

  # PyPI tarball does not ship tests
  src = fetchFromGitHub {
    owner = "sciunto-org";
    repo = "python-${pname}";
    rev = "37bd93927d1380f040d391dc132eaf04fbe279af"; # v${version}";
    sha256 = "0hp9rymvymyiysijgh0arkixwr1yf84mp7ppw3j701d0d81g2jir";
  };

  propagatedBuildInputs = [ future pyparsing ];

  checkInputs = [ nose glibcLocales unittest2 ];

  checkPhase = ''
    LC_ALL="en_US.UTF-8" nosetests
  '';

  meta = {
    description = "Bibtex parser for python 2.7 and 3.3 and newer";
    homepage = https://github.com/sciunto-org/python-bibtexparser;
    license = with lib.licenses; [ gpl3 bsd3 ];
    maintainers = with lib.maintainers; [ fridh ];
  };
}
