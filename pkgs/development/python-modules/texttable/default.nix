{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "texttable";
  version = "1.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ba399c103c825202659c4d638946c15ffc565ad7846ee0672964786f437fb57";
  };

  meta = {
    description = "A module to generate a formatted text table, using ASCII characters";
    homepage = http://foutaise.org/code/;
    license = lib.licenses.lgpl2;
  };
}