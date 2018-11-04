{ stdenv, buildPythonPackage, fetchPypi
, pytestrunner, requests, urllib3, mock, setuptools }:

buildPythonPackage rec {
  pname = "dropbox";
  version = "9.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d8d306a2a9dcf011bf5680fde52931e48c3290c671142a49c3fcd2b71e2cd748";
  };

  # Set DROPBOX_TOKEN environment variable to a valid token.
  doCheck = false;

  buildInputs = [ pytestrunner ];
  propagatedBuildInputs = [ requests urllib3 mock setuptools ];

  meta = with stdenv.lib; {
    description = "A Python library for Dropbox's HTTP-based Core and Datastore APIs";
    homepage = https://www.dropbox.com/developers/core/docs;
    license = licenses.mit;
  };
}
