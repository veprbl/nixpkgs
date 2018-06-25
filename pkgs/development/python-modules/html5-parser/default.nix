{ stdenv, buildPythonPackage, fetchPypi, pkgs, pkgconfig, chardet, lxml }:

buildPythonPackage rec {
  pname = "html5-parser";
  version = "0.4.5";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a903ef8b93b51788a6d1604b3833303e9f2f8db488306ee4241436d2f518bd06";
  };

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ chardet lxml pkgs.libxml2 ];

  doCheck = false; # No such file or directory: 'run_tests.py'

  meta = with stdenv.lib; {
    description = "Fast C based HTML 5 parsing for python";
    homepage = https://html5-parser.readthedocs.io;
    license = licenses.asl20;
  };
}
