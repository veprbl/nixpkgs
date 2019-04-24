{ stdenv
, lib
, fetchFromGitHub
, groff
, cmake
, python2
, perl
, libffi
, libbfd
, libxml2
, valgrind
, ncurses
, zlib
}:

stdenv.mkDerivation rec {
  name    = "llvm-${version}";
  version = "6.0-mono-2019-03-08";

  src = fetchFromGitHub {
    owner = "mono";
    repo = "llvm";
    rev = "286f43185878a77fdc78c3303db68e514969bc30";
    sha256 = "06z1pgvn5g7qywfgagy6fnza3qbfivn91y8jvfmwpzk8mb5h17mz";
  };

  buildInputs = [ perl groff cmake libxml2 python2 libffi ] ++ lib.optional stdenv.isLinux valgrind;

  propagatedBuildInputs = [ ncurses zlib ];

  # hacky fix: created binaries need to be run before installation
  preBuild = ''
    mkdir -p $out/
    ln -sv $PWD/lib $out
  '';
  postBuild = "rm -fR $out";

  cmakeFlags = with stdenv; [
    "-DLLVM_ENABLE_FFI=ON"
    "-DLLVM_BINUTILS_INCDIR=${libbfd.dev}/include"
  ] ++ stdenv.lib.optional (!isDarwin) "-DBUILD_SHARED_LIBS=ON";

  enableParallelBuilding = true;

  meta = {
    description = "Collection of modular and reusable compiler and toolchain technologies - Mono build";
    homepage    = http://llvm.org/;
    license     = stdenv.lib.licenses.bsd3;
    maintainers = with stdenv.lib.maintainers; [ thoughtpolice ];
    platforms   = stdenv.lib.platforms.all;
  };
}
