{ buildPythonPackage, lib, fetchPypi, nose, coverage }:

buildPythonPackage rec {
  pname = "isbnlib";
  version = "3.9.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "84a33ea57804d0329df7875cc48ac5ad2bab5a4c1c8f8bd177bafea10f79917e";
  };

  postUnpack = "mv $sourceRoot/{COPYRIGHT.txt,LICENSE}";

  doCheck = false; # XXX: network but can probably be asked to omit those
  checkInputs = [ nose coverage ];

  meta = with lib; {
    homepage = https://github.com/xlcnd/isbnlib;
    description = "Extract, clean, transform, hyphenate and metadata for ISBNs (International Standard Book Number)";
    license = licenses.lgpl3;
  };
}
