{ buildPythonPackage, lib, fetchPypi }:

buildPythonPackage rec {
  pname = "filetype";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "97b4ec0974b07cbddb3e74cf323d8688749807014055cc91cdbfef5442a94dc5";
  };

  doCheck = false; # XXX: missing dep? not sure

  meta = with lib; {
    homepage = https://github.com/h2non/filetype.py;
    description = "Small and fast Python package to infer file types checking the magic numbers signature";
    license = licenses.mit;
  };
}
