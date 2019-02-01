{ stdenv, fetch, cmake, isl, python, gmp, llvm, version }:

stdenv.mkDerivation {
  name = "polly${version}";

  src = fetch "polly" "0wgvayfilgb530bq51l7szxfb13l24nnrmyji2f6ncq95a24dw8v";

  nativeBuildInputs = [ cmake isl python gmp ];
  buildInputs = [ llvm ];

  enableParallelBuilding = true;

  meta = {
    description = "Polyhedral Optimizations for LLVM";
    homepage    = http://polly.llvm.org/;
    license     = stdenv.lib.licenses.ncsa;
    platforms   = stdenv.lib.platforms.all;
  };
}
