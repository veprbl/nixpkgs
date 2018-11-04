{ stdenv, buildPythonPackage, fetchPypi, pbr, six, argparse }:

buildPythonPackage rec {
  pname = "stevedore";
  version = "1.30.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "b92bc7add1a53fb76c634a178978d113330aaf2006f9498d9e2414b31fbfc104";
  };

  doCheck = false;

  propagatedBuildInputs = [ pbr six argparse ];

  meta = with stdenv.lib; {
    description = "Manage dynamic plugins for Python applications";
    homepage = https://pypi.python.org/pypi/stevedore;
    license = licenses.asl20;
  };
}
