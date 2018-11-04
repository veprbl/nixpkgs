{ stdenv, fetchPypi, buildPythonPackage
, pkgconfig
, libgphoto2 }:

buildPythonPackage rec {
  pname = "gphoto2";
  version = "1.8.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "140d1a1e8bb3960f6eca1374532ff5561ff5a340b9cedf78fd2a8a2cf1c17ccb";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ libgphoto2 ];

  doCheck = false; # No tests available

  meta = with stdenv.lib; {
    description = "Python interface to libgphoto2";
    homepage = https://github.com/jim-easterbrook/python-gphoto2;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jfrankenau ];
  };
}
