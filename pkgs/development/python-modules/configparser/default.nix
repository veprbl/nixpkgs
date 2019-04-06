{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "configparser";
  version = "3.7.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0xac32886ihs2xg7w1gppcq2sgin5qsm8lqwijs5xifq9w0x0q6s";
  };

  # No tests available
  doCheck = false;

  preConfigure = ''
    export LC_ALL=${if stdenv.isDarwin then "en_US" else "C"}.UTF-8
  '';

  meta = with stdenv.lib; {
    description = "Updated configparser from Python 3.7 for Python 2.6+.";
    license = licenses.mit;
    homepage = https://github.com/jaraco/configparser;
  };
}
