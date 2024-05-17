{ lib
, stdenv
, fetchFromGitHub
, cmake
, makeWrapper
, nlohmann_json
, python3
, spdlog
}:

stdenv.mkDerivation rec {
  pname = "prmon";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "HSF";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-eKUFFuOATSG6SF49u25Wx61mFYX6cxkSnsxABVb/3yE=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    nlohmann_json
    spdlog
    python3
    python3.pkgs.matplotlib
    python3.pkgs.numpy
    python3.pkgs.pandas
    python3.pkgs.seaborn
  ];

  postInstall = ''
    patchShebangs --host "$out"/bin

    for prog in "$out"/bin/*; do
      wrapProgram "$prog" --set PYTHONPATH $PYTHONPATH:$(toPythonPath "$out")
    done
  '';

  meta = with lib; {
    description = "Standalone monitor for process resource consumption ";
    homepage = "https://github.com/HSF/prmon";
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ veprbl ];
    platforms = lib.platforms.linux;
  };
}
