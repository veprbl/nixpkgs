{ lib
, buildPythonPackage
, fetchPypi
, click
, mock
, pytest
, futures
, google_auth
, requests_oauthlib
, isPy27
}:

buildPythonPackage rec {
  pname = "google-auth-oauthlib";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "03rq2rjac0zh16vsw0q914sp62l9f8fp033wn3191pqd2cchqix0";
  };

  checkInputs = [ click mock pytest ] ++ lib.optional isPy27 futures;

  propagatedBuildInputs = [
    google_auth requests_oauthlib
  ];

  checkPhase = ''
    py.test
  '';

  meta = with lib; {
    description = "Google Authentication Library: oauthlib integration";
    homepage = https://github.com/GoogleCloudPlatform/google-auth-library-python-oauthlib;
    license = licenses.asl20;
    maintainers = with maintainers; [ terlar ];
  };
}
