{ stdenv, fetchFromGitHub
, cmake, ninja
, python3, which, swig
, libxml2, libffi, libbfd
, libedit
, ncurses, zlib
, enableProjects ? [
  "clang" "libcxx" "libcxxabi" "libunwind" "lldb"
  "compiler-rt" "lld" "polly" "debuginfo-tests"
 ] ++ [ "pstore" /* rld */ ]
}:

let
src = fetchFromGitHub {
  owner = "SNSystems";
  repo = "llvm-project-prepo";
  #rev = "llvmorg-8.0.0";
  rev = "6baf80d6dc73e3c42ac102c15d8517eb070a40b6";
  sha256 = "1gqj5hw9fl372gvynchfli9mdlpdyzvibhzgg07xiyp30s2qhx4b";
};
pstore_src = fetchFromGitHub {
  owner = "SNSystems";
  name = "pstore";
  repo = "pstore";
  #rev = "llvmorg-8.0.0";
  rev = "dfde10770050191202706640f67a92b5bb2a5ee4"; # 2019-04-24
  sha256 = "1ivc3jvayjpi8sbsgmhxx4sg9a6xnqxajf55zs5xmixaj4m4vffv";
};
self = stdenv.mkDerivation rec {
  pname = "llvm-project-prepo";
  #version = "8.0.0";
  version = "2019-03-27";

  srcs = [ src pstore_src ];

  sourceRoot = "source";

  nativeBuildInputs = [ cmake ninja python3 which swig ];

  buildInputs = [ libxml2 libffi libbfd libedit ];
  propagatedBuildInputs = [ ncurses zlib ];

  preConfigure = "ln -rs ../pstore; cd llvm";

  postPatch = ''
    patch -p1 -d clang -i ${clang/purity.patch}
    sed -i -e 's/DriverArgs.hasArg(options::OPT_nostdlibinc)/true/' \
           -e 's/Args.hasArg(options::OPT_nostdlibinc)/true/' \
           clang/lib/Driver/ToolChains/*.cpp

  '';

  cmakeFlags = [
    #"-DLLVM_ENABLE_PROJECTS=clang;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;pstore;rld;debuginfo-tests"
    "-DLLVM_ENABLE_PROJECTS=${builtins.concatStringsSep ";" enableProjects}"
    "-DLLVM_TARGETS_TO_BUILD=host"
    "-DLLVM_TOOL_CLANG_TOOLS_EXTRA_BUILD=OFF"

    "-DLLVM_HOST_TRIPLE=${stdenv.hostPlatform.config}"
    "-DLLVM_DEFAULT_TARGET_TRIPLE=${stdenv.hostPlatform.config}"

    # Can't set this, pstore wants to be statically linked
    # XXX: investigate!
    #"-DLLVM_LINK_LLVM_DYLIB=ON"

    "-DLLVM_BINUTILS_INCDIR=${libbfd.dev}/include"
  ];

  postInstall = ''
      ln -sv $out/bin/clang $out/bin/cpp
  '';

  passthru = {
    isClang = true;
    llvm = self;
    #inherit llvm;
  } // stdenv.lib.optionalAttrs (stdenv.targetPlatform.isLinux || (stdenv.cc.isGNU && stdenv.cc.cc ? gcc)) {
    # lol :(
    gcc = if stdenv.cc.isGNU then stdenv.cc.cc else stdenv.cc.cc.gcc;
  };
}; in self
