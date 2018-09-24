{ stdenv
, fetchFromGitHub
, cmake
, libxml2
, llvm
, version
}:

stdenv.mkDerivation {
  name = "lld-${version}";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "lld";
    rev = "762d7b4dda20905f1e27a8abf80549a47fd1d8b4";
    sha256 = "00n9v0bzasi05lmc0xy382fl1307hqd99d8q3d41dqb8nm1wy8by";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm libxml2 ];

  outputs = [ "out" "dev" ];

  enableParallelBuilding = true;

  postInstall = ''
    moveToOutput include "$dev"
    moveToOutput lib "$dev"
  '';

  meta = {
    description = "The LLVM Linker";
    homepage    = http://lld.llvm.org/;
    license     = stdenv.lib.licenses.ncsa;
    platforms   = stdenv.lib.platforms.all;
  };
}
