{ stdenv, fetchurl, gdal, cmake, qt4, flex, bison, proj, geos, xlibsWrapper, sqlite, gsl
, qwt, fcgi, python2Packages, libspatialindex, libspatialite, qscintilla, postgresql, makeWrapper
, qjson, qca2, txt2tags, openssl
, ApplicationServices, IOKit
, withGrass ? false, grass
}:

stdenv.mkDerivation rec {
  name = "qgis-2.18.1";

  buildInputs = [ gdal qt4 flex openssl bison proj geos xlibsWrapper sqlite gsl qwt qscintilla
    fcgi libspatialindex libspatialite postgresql qjson qca2 txt2tags ] ++
    (stdenv.lib.optional withGrass grass) ++
    (with python2Packages; [ numpy psycopg2 requests2 python2Packages.qscintilla sip ])
    ++ stdenv.lib.optionals (stdenv.isDarwin) [ ApplicationServices IOKit ];

  nativeBuildInputs = [ cmake makeWrapper ];

  # fatal error: ui_qgsdelimitedtextsourceselectbase.h: No such file or directory
  enableParallelBuilding = false;

  # To handle the lack of 'local' RPATH; required, as they call one of
  # their built binaries requiring their libs, in the build process.
  preBuild = ''
    export LD_LIBRARY_PATH=`pwd`/output/lib:${stdenv.lib.makeLibraryPath [ openssl ]}:$LD_LIBRARY_PATH
  '';

  patches = [ ./darwin-override-minimum-required-clang-version.patch ];

  VERBOSE = 1;

  postPatch = ''
    substituteInPlace src/core/qgis.h --replace "[[clang::fallthrough]]" ""
  '';

  src = fetchurl {
    url = "http://qgis.org/downloads/${name}.tar.bz2";
    sha256 = "052nxps2kxv4p98iikbmk7la1bv18a399mbcfycfl3qn0nf6ww6v";
  };

  cmakeFlags = ["-DWITH_QTWEBKIT=FALSE"] ++stdenv.lib.optional withGrass "-DGRASS_PREFIX7=${grass}/${grass.name}";

  postInstall = ''
    wrapProgram $out/bin/qgis \
      --prefix PYTHONPATH : $PYTHONPATH \
      --prefix LD_LIBRARY_PATH : ${stdenv.lib.makeLibraryPath [ openssl ]}
  '';

  meta = {
    description = "User friendly Open Source Geographic Information System";
    homepage = http://www.qgis.org;
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = with stdenv.lib.platforms; linux;
    maintainers = with stdenv.lib.maintainers; [viric];
  };
}
