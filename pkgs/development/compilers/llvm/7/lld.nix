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
    rev = "21f9d854a0a578c7b9892dd16fe104c3b0c54953";
    sha256 = "0mk98q4yggfq0m093j2c3rc4nygb55877s46k4jclhrv9k2479qg";
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
