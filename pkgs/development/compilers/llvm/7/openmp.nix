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

  # build system reports that tests are only enabled when building with clang > 6.0
  # Disable tests w/musl since they mostly pass but a few don't and it appears
  # to be due to hardcoded '-gnu' triples, although only briefly investigated.
  doCheck = stdenv.cc.isClang && !stdenv.hostPlatform.isMusl;
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
