{ stdenv, buildPythonPackage, fetchPypi
, google_api_core, pytest, mock }:

buildPythonPackage rec {
  pname = "google-cloud-speech";
  version = "0.36.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6e756ad9e699545877d20bb536b9b8db4589b632177835275c11885cdc6651ca";
  };

  propagatedBuildInputs = [ google_api_core ];
  checkInputs = [ pytest mock ];

  # needs credentials
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Cloud Speech API enables integration of Google speech recognition into applications.";
    homepage = "https://googlecloudplatform.github.io/google-cloud-python/latest/speech/";
    license = licenses.asl20;
    maintainers = with maintainers; [ vanschelven ];
  };
}
