{ stdenv
, fetch
, cmake
, llvm
, perl
, version
, pkgconfig
, libffi
, libelf
}:

stdenv.mkDerivation {
  name = "openmp-${version}";

  src = fetch "openmp" "1zrqlaxr954sp8lcr7g8m0z0pr8xyq4i6p11x6gcamjm5xijnrih";

  nativeBuildInputs = [ cmake perl pkgconfig ];
  buildInputs = [ llvm libffi libelf /* cuda */ ];

  enableParallelBuilding = true;

  meta = {
    description = "Components required to build an executable OpenMP program";
    homepage    = http://openmp.llvm.org/;
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.all;
  };
}
