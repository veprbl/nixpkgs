{ lib, python3Packages, fetchFromGitHub, cmake, clang-analyzer }:
python3Packages.buildPythonApplication rec {
  version = "1.2";
  name = "scan-build-${version}";

  src = fetchFromGitHub {
    owner = "rizsotto";
    repo = "scan-build";
    rev = "pip-${version}";
    sha256 = "060irnhfisky26j072i6lq8498mml9pgaflhjl4l3f79bvf73piz";
  };

  buildInputs = [ cmake clang-analyzer ]; # tools needed for testing
  doCheck = false;

  meta = with lib; {
    homepage = https://github.com/rizsotto/scan-build;
    description = "Clang's scan-build re-implementation in python";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
