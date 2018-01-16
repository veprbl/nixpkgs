{ stdenv
, llvm # source
, cmake
, python
, version
}:

stdenv.mkDerivation {
  name = "llvm-tblgen-${version}";
  inherit (llvm) src unpackPhase postPatch;

  nativeBuildInputs = [ cmake python ];

  buildFlags = [ "llvm-tblgen" ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/llvm-tblgen $out/bin/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tablegen utility from LLVM";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.ncsa;
    maintainers = with stdenv.lib.maintainers; [ lovek323 raskin viric dtzWill ];
    platforms   = stdenv.lib.platforms.all;
  };
}
