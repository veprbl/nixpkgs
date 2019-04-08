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
  rev = "5b37f43ef3c12d9a380fbdfb9caa122fc170ea90";
  sha256 = "1xhi3q5qpw9w1szga796njjn7wzayv6b29nv8jaj2q0va376j6rh";
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
