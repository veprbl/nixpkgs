{ lib, buildPythonPackage, fetchPypi, requests }:

buildPythonPackage rec {
  pname = "casttube";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0g7mksfl341vfsxqvw8h15ci2qwd1rczg41n4fb2hw7y9rikqnzj";
  };

  propagatedBuildInputs = [ requests ];

  doCheck = false; # network or X session?

  meta = with lib; {
    homepage = http://github.com/ur1katz/casttube;
    description = "YouTube chromecast api";
    license = licenses.mit;
  };
}
