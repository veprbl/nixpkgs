{ stdenv, fetchurl, pkgconfig, meson, ninja, libpthreadstubs, libpciaccess, valgrind-light }:

stdenv.mkDerivation rec {
  pname = "libdrm";
  version = "2.4.98";

  src = fetchurl {
    url = "https://dri.freedesktop.org/${pname}/${pname}-${version}.tar.bz2";
    sha256 = "150qdzsm2nx6dfacc75rx53anzsc6m31nhxidf5xxax3mk6fvq4b";
  };

  outputs = [ "out" "dev" "bin" ];

  nativeBuildInputs = [ pkgconfig meson ninja ];
  buildInputs = [ libpthreadstubs libpciaccess valgrind-light ];
    # libdrm as of 2.4.70 does not actually do anything with udev.

  postPatch = ''
    for a in */*-symbol-check ; do
      patchShebangs $a
    done
  '' + stdenv.lib.optionalString stdenv.hostPlatform.isMusl ''
    substituteInPlace tests/meson.build \
      --replace "subdir('nouveau')" ""
  '';

  mesonFlags = [ "-Dinstall-test-programs=true" ]
    ++ stdenv.lib.optionals (stdenv.isAarch32 || stdenv.isAarch64)
      [ "-Dtegra=true" "-Detnaviv=true" ]
    ++ stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "-Dintel=false"
    ;

  meta = {
    homepage = https://dri.freedesktop.org/libdrm/;
    description = "Library for accessing the kernel's Direct Rendering Manager";
    license = "bsd";
    platforms = stdenv.lib.platforms.unix;
  };
}
