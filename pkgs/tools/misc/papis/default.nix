{ lib, fetchFromGitHub, bashInteractive
, python3, vim
}:

let
  python = python3;

in python.pkgs.buildPythonApplication rec {
  pname = "papis";
  version = "0.7.4";

  # Missing tests on Pypi
  src = fetchFromGitHub {
    owner = "papis";
    repo = pname;
    rev = "v${version}";
    sha256 = "048rgqxbvd77kslm9z0i7g4sj1prnarnjkl46lb3jlrb7kinq11j";
  };

  postPatch = ''
    sed -i setup.py \
      -e 's/configparser>=3.0.0/#\0/' \
      -e 's/python-slugify==1.2.5/python-slugify==1.2.6/'

    patchShebangs tests
  '';

  propagatedBuildInputs = with python.pkgs; [
    pyyaml
    arxiv2bib beautifulsoup4 bibtexparser
    chardet click configparser filetype habanero
    isbnlib prompt_toolkit2 pylibgen pyparser pyparsing
    python-slugify requests

    # Not mentioned but keeping for now "just in case"
    argcomplete dmenu-python papis-python-rofi python_magic
    unidecode vobject tkinter whoosh
    vim
  ];

  checkInputs = with python.pkgs; [ pytest ];

  # Papis tries to create the config folder under $HOME during the tests
  checkPhase = ''
    mkdir -p check-phase
    export PATH=$out/bin:$PATH
    # Still don't know why this fails
    #sed -i 's/--set dir=hello //' tests/bash/test_default.sh

    # This test has been disabled since it requires a network connaction
    sed -i 's/test_downloader_getter(self):/disabled_test_downloader_getter(self):/' papis/downloaders/tests/test_main.py

    export HOME=$(pwd)/check-phase
    make test
    SH=${bashInteractive}/bin/bash make test-non-pythonic
  '';

  meta = {
    description = "Powerful command-line document and bibliography manager";
    homepage = http://papis.readthedocs.io/en/latest/;
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.nico202 ];
  };
}
