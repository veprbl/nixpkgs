{ stdenv, fetchurl, fetchpatch, cmake, pcre, pkgconfig, python2
, libX11, libXpm, libXft, libXext, zlib, lzma, gsl, Cocoa }:

stdenv.mkDerivation rec {
  name = "root-${version}";
  version = "5.34.36";

  src = fetchurl {
    url = "https://root.cern.ch/download/root_v${version}.source.tar.gz";
    sha256 = "1kbx1jxc0i5xfghpybk8927a0wamxyayij9c74zlqm0595gqx1pw";
  };

  buildInputs = [ cmake pcre pkgconfig python2 zlib lzma gsl ]
    ++ stdenv.lib.optionals (!stdenv.isDarwin) [ libX11 libXpm libXft libXext ]
    ++ stdenv.lib.optionals (stdenv.isDarwin) [ Cocoa ]
    ;

  patches = [
    ./sw_vers_root5.patch

    # this prevents thisroot.sh from setting $p, which interferes with stdenv setup
    ./thisroot.patch
  ];

  preConfigure = ''
    patchShebangs build/unix/
    substituteInPlace cint/cint/lib/posix/posix.h \
      --replace __DARWIN_UNIX03 1
  '';


  cmakeFlags = [
    "-Drpath=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-Dalien=OFF"
    "-Dbonjour=OFF"
    "-Dcastor=OFF"
    "-Dchirp=OFF"
    "-Ddavix=OFF"
    "-Ddcache=OFF"
    "-Dfftw3=OFF"
    "-Dfitsio=OFF"
    "-Dfortran=OFF"
    "-Dgfal=OFF"
    "-Dgviz=OFF"
    "-Dhdfs=OFF"
    "-Dkrb5=OFF"
    "-Dldap=OFF"
    "-Dmonalisa=OFF"
    "-Dmysql=OFF"
    "-Dodbc=OFF"
    "-Dopengl=OFF"
    "-Doracle=OFF"
    "-Dpgsql=OFF"
    "-Dpythia6=OFF"
    "-Dpythia8=OFF"
    "-Drfio=OFF"
    "-Dsqlite=OFF"
    "-Dssl=OFF"
    "-Dxml=OFF"
    "-Dxrootd=OFF"
  ]
  ++ stdenv.lib.optional (stdenv.cc.libc != null) "-DC_INCLUDE_DIRS=${stdenv.lib.getDev stdenv.cc.libc}/include";

  enableParallelBuilding = true;

  setupHook = ./setup-hook.sh;

  meta = {
    homepage = "https://root.cern.ch/";
    description = "A data analysis framework";
    platforms = stdenv.lib.platforms.unix;
    maintainers = with stdenv.lib.maintainers; [ veprbl ];
  };
}
