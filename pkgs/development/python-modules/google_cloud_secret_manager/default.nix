{ lib, buildPythonPackage, fetchPypi
, grpc_google_iam_v1, google_api_core, libcst, proto-plus
, pytest, mock
}:

buildPythonPackage rec {
  pname = "google-cloud-secret-manager";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1w2q602ww8s3n714l2gnaklqzbczshrspxvmvjr6wfwwalxwkc62";
  };

  propagatedBuildInputs = [
    google_api_core
    grpc_google_iam_v1
    libcst
    proto-plus
  ];

  checkInputs = [
    mock
    pytest
  ];
  checkPhase = ''
    pytest
  '';

  meta = with lib; {
    description = "Secret Manager API: Stores, manages, and secures access to application secrets";
    homepage = "https://github.com/GoogleCloudPlatform/google-cloud-python";
    license = licenses.asl20;
    maintainers = with maintainers; [ siriobalmelli ];
  };
}
