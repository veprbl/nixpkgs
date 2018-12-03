{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  version = "0.6.2-git";
  name = "reptyr-${version}";
  src = fetchFromGitHub {
    owner = "nelhage";
    repo = "reptyr";
    #rev = "reptyr-${version}";
    rev = "44b961829ff876a9ba8ef6f75682bb477a3084c5";
    sha256 = "1vhhwdhi04vijf9z0w61ks1i49ldgkahkxq81zflvjim1xvg5crr";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "BASHCOMPDIR=${placeholder "out"}/share/bash-completion/completions"
  ];

  meta = {
    platforms = [
      "i686-linux"
      "x86_64-linux"
      "i686-freebsd"
      "x86_64-freebsd"
    ] ++ lib.platforms.arm;
    maintainers = with lib.maintainers; [raskin];
    license = lib.licenses.mit;
    description = "Reparent a running program to a new terminal";
    homepage = https://github.com/nelhage/reptyr;
  };
}
