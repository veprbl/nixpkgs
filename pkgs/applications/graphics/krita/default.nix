{ stdenv, mkDerivation, lib, fetchurl, fetchpatch, cmake, extra-cmake-modules
, karchive, kconfig, kwidgetsaddons, kcompletion, kcoreaddons
, kguiaddons, ki18n, kitemmodels, kitemviews, kwindowsystem
, kio, kcrash
, boost, libraw, fftw, eigen, exiv2, lcms2, gsl, openexr
, openjpeg, opencolorio, vc, poppler_qt5, curl, ilmbase
, qtmultimedia, qtx11extras, qtsvg
, xcbuild, QuickLook, CoreFoundation, CoreServices
}:

mkDerivation rec {
  name = "krita-${version}";
  version = "4.0.0";

  src = fetchurl {
    url = "https://download.kde.org/stable/krita/${version}/${name}.tar.gz";
    sha256 = "0dh3bm90mxrbyvdp7x7hcf5li48j7ppkb44lls65lpn6c59r5waz";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  patches = [
    ./no-known-features-for-CXX-compiler.patch
  ];

  postPatch = ''
    echo "Disabling the Krita-QuickLook build" # TODO!
    substituteInPlace krita/CMakeLists.txt --replace "add_subdirectory( integration )" " "
  '';

  buildInputs = [
    kwindowsystem
    karchive
    kconfig
    kcompletion
    kcoreaddons
    kguiaddons
    ki18n
    kitemmodels
    kitemviews
    kwidgetsaddons
    boost
    libraw
    eigen
    exiv2
    fftw
    ilmbase
    openjpeg
    lcms2
    openexr
    gsl
    vc
  ] ++ lib.optionals (!stdenv.isDarwin) [
    qtmultimedia  kio kcrash
     opencolorio  poppler_qt5 curl 
     qtx11extras
  ] ++ lib.optionals stdenv.isDarwin [
    qtsvg # Check why current linux build doesn't need this
    # xcbuild QuickLook CoreFoundation CoreServices # Needed for kritaquicklook
  ];

  preConfigure = ''
    cmakeFlags="$cmakeFlags -DKDE_INSTALL_BUNDLEDIR=$out/Applications"
  '';

  dontUseXcbuild = true;

  NIX_CFLAGS_COMPILE = [ "-I${ilmbase.dev}/include/OpenEXR" ];

  meta = with lib; {
    description = "A free and open source painting application";
    homepage = https://krita.org/;
    maintainers = with maintainers; [ abbradar ];
    platforms = platforms.unix;
    license = licenses.gpl2;
  };
}
