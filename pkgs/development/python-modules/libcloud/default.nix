{ stdenv
, buildPythonPackage
, fetchPypi
, mock
, pycrypto
, requests
}:

buildPythonPackage rec {
  pname = "apache-libcloud";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0daj3mkzw79v5zin2r1s2wkrz1hplfc16bwj4ss68i5qjq4l2p0j";
  };

  buildInputs = [ mock ];
  propagatedBuildInputs = [ pycrypto requests ];

  preConfigure = "cp libcloud/test/secrets.py-dist libcloud/test/secrets.py";

  # failing tests for 26 and 27
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A unified interface to many cloud providers";
    homepage = http://incubator.apache.org/libcloud/;
    license = licenses.asl20;
  };

}
