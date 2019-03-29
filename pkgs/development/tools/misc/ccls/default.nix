{ stdenv, fetchFromGitHub, makeWrapper
, cmake, llvmPackages, rapidjson, runtimeShell }:

stdenv.mkDerivation rec {
  name    = "ccls-${version}";
  version = "0.20190329";

  src = fetchFromGitHub {
    owner = "MaskRay";
    repo = "ccls";
    #rev = version;
    rev = "556ad0aeb50203817d0f08f9ffa52389f75435a5";
    sha256 = "0y1ff547d5nxx5y754xqkkbffzwsdgh5mb08rzn37b47vlgfazka";
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
