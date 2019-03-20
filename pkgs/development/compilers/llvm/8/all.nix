{ stdenv, fetchFromGitHub
, cmake
, python3, which, swig
, libxml2, libffi, libbfd
, libedit
, ncurses, zlib
 }:

stdenv.mkDerivation rec {
  pname = "llvm-project";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "llvm";
    repo = "llvm-project";
    rev = "llvmorg-8.0.0";
    sha256 = "052h16wjcnqginzp7ki4il2xmm25v9nyk0wcz7cg03gbryhl7aqa";
  };

  nativeBuildInputs = [ cmake python3 which swig ];

  buildInputs = [ libxml2 libffi libbfd libedit ];
  propagatedBuildInputs = [ ncurses zlib ];

  preConfigure = "cd llvm";

  cmakeFlags = [
    "-DLLVM_ENABLE_PROJECTS=all"
  ];
}
