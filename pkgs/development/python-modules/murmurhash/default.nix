{ stdenv
, buildPythonPackage
, fetchPypi
, cython
}:

buildPythonPackage rec {
  pname = "murmurhash";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "38e91cd5ae5192b8f63cfe756cc784bf0cd44f64a15e496ba0a6fddda3f48b0b";
  };

  postPatch = ''
    substituteInPlace setup.py --replace "'wheel>=0.32.0,<0.33.0'" ""
  '';

  buildInputs = [
   cython
  ];

  # No test
  doCheck = false;

  checkPhase = ''
    pytest murmurhash
  '';

  meta = with stdenv.lib; {
    description = "Cython bindings for MurmurHash2";
    homepage = https://github.com/explosion/murmurhash;
    license = licenses.mit;
    maintainers = with maintainers; [ aborsu sdll ];
  };
}
