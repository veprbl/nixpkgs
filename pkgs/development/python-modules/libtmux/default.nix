{ stdenv, fetchPypi, buildPythonPackage, pytest }:

buildPythonPackage rec {
  pname = "libtmux";
  version = "0.7.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "3dacce93790a93d4b1a70eb4a6ea5db6a49dcf6599c277e89c1a8de742d9b89e";
  };

  checkInputs = [ pytest ];
  postPatch = ''
    sed -i 's/==.*$//' requirements/test.txt
  '';

  # No tests in archive
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Scripting library for tmux";
    homepage = https://libtmux.readthedocs.io/;
    license = licenses.bsd3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jgeerds ];
  };
}

