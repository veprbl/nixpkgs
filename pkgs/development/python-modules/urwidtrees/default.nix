{ stdenv
, buildPythonPackage
, fetchFromGitHub
, urwid
}:

buildPythonPackage rec {
  pname = "urwidtrees";
  version  = "1.0.2.1"; # not really
  #version  = "1.0.2";

  src = fetchFromGitHub {
    owner = "pazz";
    repo = "urwidtrees";
    rev = "d1fa38ce4f37db00bdfc574b856023b5db4c7ead";
    sha256 = "18zyq94f5vpyxavr20183jn94h9kxan3v5cnv1pfwgkx1qnahjiq";
  };

  propagatedBuildInputs = [ urwid ];

  meta = with stdenv.lib; {
    description = "Tree widgets for urwid";
    homepage = https://github.com/pazz/urwidtrees;
    license = licenses.gpl3;
  };

}
