{ stdenv, fetchFromGitHub, cmake, makeWrapper
, llvmPackages_4, hiredis, z3, gtest
}:

let
  klee = fetchFromGitHub {
    owner = "rsas";
    repo  = "klee";
    # branch "pure-bv-qf-llvm-7.0"
    rev   = "211d8fbdba6df025379ba0f3cbe61e3c700e149f";
    sha256 = "0rbj6bmcgylffyrg1li7rgy8va51r09yk3s28hmw81impn1s0f1m";
  };
in stdenv.mkDerivation rec {
  name = "souper-unstable-${version}";
  version = "2018-09-19";

  src = fetchFromGitHub {
    owner  = "google";
    repo   = "souper";
    rev    = "db7033e694f97a2d800e8686c80a572b03b65404";
    sha256 = "0nsnhlikblhixj0f7sby81765jjgszbb6ixqwv5fmc7h88pp6jj7";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    llvmPackages_4.llvm
    llvmPackages_4.clang-unwrapped
    hiredis
    gtest
  ];

  patches = [ ./cmake-fix.patch ];

  enableParallelBuilding = true;

  preConfigure = ''
      mkdir -pv third_party
      cp -R "${klee}" third_party/klee
  '';

  installPhase = ''
      mkdir -pv $out/bin
      cp -v ./souper       $out/bin/
      cp -v ./clang-souper $out/bin/
      wrapProgram "$out/bin/souper" \
          --add-flags "-z3-path=\"${z3}/bin/z3\""
  '';

  meta = with stdenv.lib; {
    description = "A superoptimizer for LLVM IR";
    homepage    = "https://github.com/google/souper";
    license     = licenses.asl20;
    maintainers = with maintainers; [ taktoa ];
    platforms   = with platforms; linux;
  };
}
