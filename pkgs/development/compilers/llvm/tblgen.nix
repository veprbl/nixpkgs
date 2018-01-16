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

  cmakeFlags = [
    "-DCOMPILER_RT_CAN_EXECUTE_TESTS=OFF"
    "-DLLVM_BUILD_TESTS=OFF"
    "-DLLVM_ENABLE_TERMINFO=OFF"
    "-DLLVM_TARGETS_TO_BUILD=host"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp bin/llvm-tblgen $out/bin/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tablegen utility from LLVM";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.ncsa;
    maintainers = with stdenv.lib.maintainers; [ dtzWill ];
    platforms   = stdenv.lib.platforms.all;
  };
}
