{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "toml";
  version = "0.10.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "229f81c57791a41d65e399fc06bf0848bab550a9dfd5ed66df18ce5f05e73d5c";
  };

  # This package has a test script (built for Travis) that involves a)
  # looking in the home directory for a binary test runner and b) using
  # git to download a test suite.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "a Python library for parsing and creating TOML";
    homepage = "https://github.com/uiri/toml";
    license = licenses.mit;
    maintainers = with maintainers; [ twey ];
  };
}
