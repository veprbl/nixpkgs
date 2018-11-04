{ stdenv
, buildPythonPackage
, fetchPypi
, unittest2
, pyasn1
}:

buildPythonPackage rec {
  pname = "rsa";
  version = "4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1a836406405730121ae9823e19c6e806c62bbad73f890574fff50efa4122c487";
  };

  nativeBuildInputs = [ unittest2 ];
  propagatedBuildInputs = [ pyasn1 ];

  meta = with stdenv.lib; {
    homepage = https://stuvel.eu/rsa;
    license = licenses.asl20;
    description = "A pure-Python RSA implementation";
  };

}
