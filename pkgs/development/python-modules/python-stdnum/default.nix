{ lib, fetchPypi, buildPythonPackage, isPy3k }:

buildPythonPackage rec {
  version = "1.10";
  pname = "python-stdnum";
  # Failing tests and dependency issue on Py3k
  disabled = isPy3k;
  src = fetchPypi {
    inherit pname version;
    sha256 = "caa050aed5d1d4825cc3294c99dc03d498aaf71f4415d659c9fcb58ff0303a5f";
  };
  meta = {
    homepage = https://arthurdejong.org/python-stdnum/;
    description = "Python module to handle standardized numbers and codes";
    maintainers = with lib.maintainers; [ johbo ];
    license = lib.licenses.lgpl2Plus;
  };
}
