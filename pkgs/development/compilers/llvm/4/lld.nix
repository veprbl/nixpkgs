{ stdenv
, fetch
, cmake
, zlib
, llvm
, python
, lit ? python.pkgs.lit
, version
}:

stdenv.mkDerivation {
  name = "lld-${version}";

  src = fetch "lld" "0kmyp7iyf4f76wgy87jczkyhvzhlwfydvxgggl74z0x89xgry745";

  buildInputs = [ cmake llvm lit ];

  outputs = [ "out" "dev" ];

  enableParallelBuilding = true;

  # doCheck = true;

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
