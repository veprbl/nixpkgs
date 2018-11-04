{ stdenv
, buildPythonPackage
, fetchPypi
, numpy
, decorator
, imageio
, tqdm
}:

buildPythonPackage rec {
  pname = "moviepy";
  version = "0.2.3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "536ea61c2c7d276ee65daf2da8a1d2e34bbafd524d6e8a20fde38ce9bfbd2dcb";
  };

  # No tests
  doCheck = false;
  propagatedBuildInputs = [ numpy decorator imageio tqdm ];

  meta = with stdenv.lib; {
    description = "Video editing with Python";
    homepage = http://zulko.github.io/moviepy/;
    license = licenses.mit;
  };

}
