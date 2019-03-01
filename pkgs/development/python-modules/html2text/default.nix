{ stdenv
, buildPythonPackage
, fetchPypi
, fetchFromGitHub
, coverage
}:

buildPythonPackage rec {
  pname = "html2text";
  version = "2019.3.1"; # "2018.1.9";

  #src = fetchPypi {
  #  inherit pname version;
  #  sha256 = "627514fb30e7566b37be6900df26c2c78a030cc9e6211bda604d8181233bcdd4";
  #};
  src = fetchFromGitHub {
    owner = "Alir3z4";
    repo = pname;
    rev = "52bfc27e6a69e6f5e171b6035419c3c1457d864c";
    sha256 = "01c5c3vhy0jmcsfzbnb5pi8piw9ibnf3kvi6a0hka69fj1dc02sb";
  };

  checkInputs = [ coverage ];

  meta = with stdenv.lib; {
    description = "Turn HTML into equivalent Markdown-structured text";
    homepage = https://github.com/Alir3z4/html2text/;
    license = licenses.gpl3;
  };

}
