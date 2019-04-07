{ stdenv, fetchFromGitHub
, cmake, ninja
, python3, which, swig
, libxml2, libffi, libbfd
, libedit
, ncurses, zlib
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
in
stdenv.mkDerivation rec {
  pname = "llvm-project-prepo";
  #version = "8.0.0";
  version = "2019-03-27";

  srcs = [ src pstore_src ];

  sourceRoot = "source";

  nativeBuildInputs = [ cmake ninja python3 which swig ];

  buildInputs = [ libxml2 libffi libbfd libedit ];
  propagatedBuildInputs = [ ncurses zlib ];

  preConfigure = "ln -rs ../pstore; cd llvm";

  cmakeFlags = [
    #"-DLLVM_ENABLE_PROJECTS=clang;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;pstore;rld;debuginfo-tests"
    "-DLLVM_ENABLE_PROJECTS=clang;libcxx;libcxxabi;libunwind;lldb;compiler-rt;lld;polly;pstore;debuginfo-tests"
  ];
}
