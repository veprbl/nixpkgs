{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  name = "tsan-syso-objects";
  src = fetchFromGitHub {
    owner  = "llvm-mirror";
    repo = "compiler-rt";
    rev = "4d9e83c2e00a1fc8aa7a1e8b367a21f731013c65";
    sha256 = "1111111111111111111111111111111111111111111111111111";
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
