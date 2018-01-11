{ stdenv
, fetchurl, autoreconfHook264, buildPackages, bison, binutils-raw
, libiberty, zlib
}:

stdenv.mkDerivation rec {
  name = "libbfd-${version}";
  inherit (binutils-raw.bintools) version src;

  outputs = [ "out" "dev" ];

  patches = binutils-raw.bintools.patches ++ [
    ../../tools/misc/binutils/build-components-separately.patch
  ];

  # We just want to build libbfd
  postPatch = ''
    cd bfd
  '';

  depsBuildBuilds = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ autoreconfHook264 bison ];
  buildInputs = [ libiberty zlib ];

  configurePlatforms = [ "build" "host" "target" ];
  configureFlags = [
    "--enable-targets=all" "--enable-64-bit-bfd"
    "--enable-install-libbfd"
    "--enable-shared"
    "--with-system-zlib"
  ];

  postInstall = stdenv.lib.optionalString (stdenv.hostPlatform != stdenv.targetPlatform) ''
    # the build system likes to move things into atypical locations
    mkdir -p $dev
    mv $out/${stdenv.hostPlatform.config}/${stdenv.targetPlatform.config}/include $dev/include
    mv $out/${stdenv.hostPlatform.config}/${stdenv.targetPlatform.config}/lib $out/lib
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "A library for manipulating containers of machine code";
    longDescription = ''
      BFD is a library which provides a single interface to read and write
      object files, executables, archive files, and core files in any format.
      It is associated with GNU Binutils, and elsewhere often distributed with
      it.
    '';
    homepage = http://www.gnu.org/software/binutils/;
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ericson2314 ];
    platforms = platforms.unix;
  };
}
