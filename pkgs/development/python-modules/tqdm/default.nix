{ lib
, buildPythonPackage
, fetchPypi
, nose
, coverage
, glibcLocales
, flake8
, stdenv
}:

buildPythonPackage rec {
  pname = "tqdm";
  version = "4.27.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a0be569511161220ff709a5b60d0890d47921f746f1c737a11d965e1b29e7b2e";
  };

  buildInputs = [ nose coverage glibcLocales flake8 ];

  postPatch = ''
    # Remove performance testing.
    # Too sensitive for on Hydra.
    rm tqdm/tests/tests_perf.py
  '';

  LC_ALL="en_US.UTF-8";

  doCheck = !stdenv.isDarwin;

  meta = {
    description = "A Fast, Extensible Progress Meter";
    homepage = https://github.com/tqdm/tqdm;
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fridh ];
  };
}
