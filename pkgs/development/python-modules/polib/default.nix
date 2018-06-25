{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "polib";
  version = "1.0.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "5affe3d915eb5b4773f4ce164817e383eea0306115cdaf9b64008b3aea8202df";
  };

  # error: invalid command 'test'
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A library to manipulate gettext files (po and mo files)";
    homepage = https://bitbucket.org/izi/polib/;
    license = licenses.mit;
  };
}
