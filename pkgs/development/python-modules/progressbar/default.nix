{ stdenv, buildPythonPackage, fetchPypi, isPy3k }:

buildPythonPackage rec {
  pname = "progressbar";
  version = "2.5";

  # https://github.com/niltonvolpato/python-progressbar/issues/54
  disabled = isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "5d81cb529da2e223b53962afd6c8ca0f05c6670e40309a7219eacc36af9b6c63";
  };

  # invalid command 'test'
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = https://pypi.python.org/pypi/progressbar;
    description = "Text progressbar library for python";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ domenkozar ];
  };
}
