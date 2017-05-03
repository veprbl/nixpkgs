{ stdenv, fetchFromGitHub, cmake, llvmPackages_34, python3, perl, flex, bison, ncurses, zlib}:

let
  #llvmBuild = llvm_34.overrideDerivation (old: {
  #  installPhase = ''
  #    find .
  #  '';
  #});
in stdenv.mkDerivation rec {
  name = "klee-unstable-2017-03-01";

  src = fetchFromGitHub {
    owner = "klee";
    repo = "klee";
    rev = "827786517026ef36f5e69c29fd429c26a934b0f7";
    sha256 = "1vz8kfrg3zyrxhina5pqg3410v5f2dcpyi6zdzk12kkqf94b73j8";
  };

  buildInputs = with llvmPackages_34; [ cmake llvm clang python3 perl flex bison ncurses zlib ];

  #configureFlags = [ "--with-llvm=${llvmBuild}" ];

  meta = with stdenv.lib; {
    description = "symbolic virtual machine";

    homepage = http://klee.llvm.org/;
    license = licenses.mit;

    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.all;
  };
}
