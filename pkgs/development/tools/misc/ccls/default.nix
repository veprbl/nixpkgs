{ stdenv, fetchFromGitHub, makeWrapper
, cmake, llvmPackages, rapidjson, runtimeShell }:

stdenv.mkDerivation rec {
  name    = "ccls-${version}";
  #version = "0.20190329";
  version = "0.20190428";

  src = fetchFromGitHub {
    owner = "MaskRay";
    repo = "ccls";
    #rev = version;
    rev = "ebeba39f659b18db7fd379201859d857dd384bc3";
    sha256 = "1lj8ngw4hdxaf544alzm3kikssibkrppfwcs94chr1g76pfqzsx6";
  };

  nativeBuildInputs = [ cmake makeWrapper ];
  buildInputs = with llvmPackages; [ all /* clang-unwrapped llvm */ rapidjson ];

  cmakeFlags = [
    #"-DLLVM_ENABLE_RTTI=ON"
    #"-DLLVM_LINK_LLVM_DYLIB=ON"
    "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12"
  ];

  shell = runtimeShell;
  postFixup = ''
    # We need to tell ccls where to find the standard library headers.

    standard_library_includes="\\\"-isystem\\\", \\\"${stdenv.lib.getDev stdenv.cc.libc}/include\\\""
    standard_library_includes+=", \\\"-isystem\\\", \\\"${llvmPackages.libcxx}/include/c++/v1\\\""
    export standard_library_includes

    wrapped=".ccls-wrapped"
    export wrapped

    mv $out/bin/ccls $out/bin/$wrapped
    substituteAll ${./wrapper} $out/bin/ccls
    chmod --reference=$out/bin/$wrapped $out/bin/ccls
  '';

  doCheck = true;

  meta = with stdenv.lib; {
    description = "A c/c++ language server powered by clang";
    homepage    = https://github.com/MaskRay/ccls;
    license     = licenses.asl20;
    platforms   = platforms.linux ++ platforms.darwin;
    maintainers = [ maintainers.mic92 ];
  };
}
