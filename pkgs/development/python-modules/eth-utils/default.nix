{ lib, fetchFromGitHub, buildPythonPackage, pytest, eth-hash, eth-typing,
  cytoolz, hypothesis }:

buildPythonPackage rec {
  pname = "eth-utils";
  version = "1.2.2";

  # Tests are missing from the PyPI source tarball so let's use GitHub
  # https://github.com/ethereum/eth-utils/issues/130
  src = fetchFromGitHub {
    owner = "ethereum";
    repo = pname;
    rev = "v${version}";
    sha256 = "018nn862d5m9r0x3mj141xx59g4hf4diz6137hiqla4d9m8fxcr7";
  };

  checkInputs = [ pytest hypothesis ];
  propagatedBuildInputs = [ eth-hash eth-typing cytoolz ];

  # setuptools-markdown uses pypandoc which is broken at the moment
  preConfigure = ''
    substituteInPlace setup.py --replace \'setuptools-markdown\' ""
  '';

  checkPhase = ''
    pytest .
  '';

  meta = {
    description = "Common utility functions for codebases which interact with ethereum";
    homepage = https://github.com/ethereum/eth-utils;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
