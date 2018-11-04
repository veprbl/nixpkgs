{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  version = "0.7.6";
  pname = "pyfiglet";

  src = fetchPypi {
    inherit pname version;
    sha256 = "97d59651b40da6ddf7e961157c480a7a04b48214d8c7231adc8c15e43aa5d722";
  };

  doCheck = false;

  meta = with stdenv.lib; {
    description = "FIGlet in pure Python";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ thoughtpolice ];
  };
}
