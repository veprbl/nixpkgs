{ stdenv, fetchFromGitHub
, cmake, ninja
, python3, which, swig
, libxml2, libffi, libbfd
, libedit
, ncurses, zlib
}:

stdenv.mkDerivation rec {
  pname = "llvm-project-prepo";
  #version = "8.0.0";
  version = "2019-03-27";

  src = fetchFromGitHub {
    owner = "SNSystems";
    repo = "llvm-project-prepo";
    #rev = "llvmorg-8.0.0";
    rev = "6baf80d6dc73e3c42ac102c15d8517eb070a40b6";
    sha256 = "1gqj5hw9fl372gvynchfli9mdlpdyzvibhzgg07xiyp30s2qhx4b";
  };

  nativeBuildInputs = [ cmake ninja python3 which swig ];

  buildInputs = [ libxml2 libffi libbfd libedit ];
  propagatedBuildInputs = [ ncurses zlib ];

  preConfigure = "cd llvm";

  cmakeFlags = [
    "-DLLVM_ENABLE_PROJECTS=all"
  ];
}
