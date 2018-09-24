{ stdenv
, fetch
, cmake
, llvm
, perl
, python
, version
, pkgconfig
, libffi
, libelf
, lit
}:

stdenv.mkDerivation rec {
  name = "openmp-${version}";

  src = fetch "openmp" "1zrqlaxr954sp8lcr7g8m0z0pr8xyq4i6p11x6gcamjm5xijnrih";

  nativeBuildInputs = [ cmake perl pkgconfig ] ++ stdenv.lib.optionals doCheck [ python lit ];
  buildInputs = [ llvm libffi libelf /* cuda */ ];

  enableParallelBuilding = true;

  doCheck = stdenv.cc.isClang; # can only test with clang >= 6.0 (according to message printed during build)
  checkTarget = "check-openmp";

  postPatch = ''
    substituteInPlace cmake/OpenMPTesting.cmake --replace \
      ' ''${PYTHON_EXECUTABLE} ''${OPENMP_LLVM_LIT_EXECUTABLE}' \
      ' ''${OPENMP_LLVM_LIT_EXECUTABLE}'
  '';

  meta = {
    description = "Components required to build an executable OpenMP program";
    homepage    = http://openmp.llvm.org/;
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.all;
  };
}
