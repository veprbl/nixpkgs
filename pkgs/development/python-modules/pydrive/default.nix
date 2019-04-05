{ lib, buildPythonPackage, fetchFromGitHub
, google_api_python_client, oauth2client, pyyaml }:

buildPythonPackage rec {
  pname = "pydrive";
  version = "2019-01-25";

  src = fetchFromGitHub {
    owner = "gsuitedevs";
    repo = pname;
    rev = "cf58f81efa67cb30f7c9b3da7d304f214a9b6d3b";
    sha256 = "00bcz85dkgp56f6hb447pdz8jxxag0hiikwhp9dbq1la34zy1zda";
  };

  propagatedBuildInputs = [ google_api_python_client oauth2client pyyaml ];

  doCheck = false; # need client_secrets.json, maybe gen one for NixOS?

  meta = with lib; {
    description = "Wrapper library of google-api-python-client that simplifies many common Google Drive API tasks";
    homepage = https://github.com/gsuitedevs/PyDrive;
    license = licenses.asl20;
    maintainers = with maintainers; [ dtzWill ];
  };
}
