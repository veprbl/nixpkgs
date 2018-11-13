{ stdenv, buildPythonPackage, fetchPypi, prompt_toolkit, docopt , jedi, pygments }:

buildPythonPackage rec {
  pname = "ptpython";
  version = "2.0.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "ebe9d68ea7532ec8ab306d4bdc7ec393701cd9bbd6eff0aa3067c821f99264d4";
  };

  propagatedBuildInputs = [ prompt_toolkit docopt jedi pygments ];

  # no tests to run
  doCheck = false;

  meta = with stdenv.lib; {
    description = "An advanced Python REPL";
    license = licenses.bsd3;
    maintainers = with maintainers; [ mlieberman85 ];
    platforms = platforms.all;
  };
}
