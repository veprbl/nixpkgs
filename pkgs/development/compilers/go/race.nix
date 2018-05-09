{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "tsan-syso-objects";
  src = fetchFromGitHub {
    owner  = "llvm-mirror";
    repo = "compiler-rt";
    rev = "9d61c78bced84866cc886f1f1111c8e51c1d52d5"; # release_60
    sha256 = "1jsabycabhgqp7045k1j6x99p78bik56nya3cswnis8gg7q0hvpv";
  };

  patches = [
    ../llvm/6/sanitizers-nongnu.patch
    ../llvm/6/sanitizers-nongnu-2.patch
  ];

  postPatch = ''
    cd lib && sed -i 's@<sys/signal.h>@<signal.h>@' **/*{cpp,cc} && cd -
  '';

  buildPhase = ''
    cd lib/tsan/go
    ./buildgo.sh
  '';

  installPhase = ''
    mkdir -p $out
    cp *syso $out/
  '';
}
