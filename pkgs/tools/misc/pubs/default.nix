{ stdenv, fetchFromGitHub, python37 /* 3.7 instead of locale fixups */ }:

let
  python3Packages = python37.pkgs;
in python3Packages.buildPythonApplication rec {
  pname = "pubs";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "pubs";
    repo = "pubs";
    rev = "v${version}";
    sha256 = "1wrwanz905r3h97ipyws25vzmx7k2pdpns8rypiy0m9arq29zc64";
  };

  propagatedBuildInputs = with python3Packages; [
    argcomplete dateutil configobj feedparser bibtexparser pyyaml requests six beautifulsoup4
  ];

  checkInputs = with python3Packages; [ pyfakefs mock ddt ];

  meta = with stdenv.lib; {
    description = "Command-line bibliography manager";
    homepage = https://github.com/pubs/pubs;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ gebner ];
  };
}
