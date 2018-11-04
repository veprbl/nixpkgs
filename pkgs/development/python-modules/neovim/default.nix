{ buildPythonPackage
, fetchPypi
, lib
, nose
, msgpack
, greenlet
, trollius
, pythonOlder
, isPyPy
}:

buildPythonPackage rec {
  pname = "neovim";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02633a4527612a9b4957d1a67f5516c4915945adc06f19610890e916437ca7a3";
  };

  checkInputs = [ nose ];

  checkPhase = ''
    nosetests
  '';

  # Tests require pkgs.neovim,
  # which we cannot add because of circular dependency.
  doCheck = false;

  propagatedBuildInputs = [ msgpack ]
    ++ lib.optional (!isPyPy) greenlet
    ++ lib.optional (pythonOlder "3.4") trollius;

  meta = {
    description = "Python client for Neovim";
    homepage = "https://github.com/neovim/python-client";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ garbas ];
  };
}
