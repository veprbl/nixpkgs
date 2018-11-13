{ lib
, buildPythonPackage
, fetchPypi
, nose
, decorator
}:

buildPythonPackage rec {
  pname = "networkx";
  # upgrade may break sage, please test the sage build or ping @timokau on upgrade
  version = "2.2";

  src = fetchPypi {
    inherit pname version;
    extension = "zip";
<<<<<<< HEAD
    sha256 = "45e56f7ab6fe81652fb4bc9f44faddb0e9025f469f602df14e3b2551c2ea5c8b";
=======
    sha256 = "12swxb15299v9vqjsq4z8rgh5sdhvpx497xwnhpnb0gynrx6zra5";
>>>>>>> origin/master
  };

  checkInputs = [ nose ];
  propagatedBuildInputs = [ decorator ];

  meta = {
    homepage = "https://networkx.github.io/";
    description = "Library for the creation, manipulation, and study of the structure, dynamics, and functions of complex networks";
    license = lib.licenses.bsd3;
  };
}
