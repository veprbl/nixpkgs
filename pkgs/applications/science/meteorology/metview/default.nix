{ stdenv, fetchurl, cmake, gfortran, qt4, grib-api, 
  libemos, eccodes, magics }:

stdenv.mkDerivation rec {
  name = "Metview-${version}";
  version = "4.7.2";

  src = fetchurl {
    url = "https://software.ecmwf.int/wiki/download/attachments/3964985/Metview-${version}-Source.tar.gz";
    sha256 = "127n54s8bgbc0xa1ln4d89mqasf30mdfld8s6wh70zfsds50c2hi";
  };

  cmakeFlags = [ "-DWITH_APPS=Qt;CLI"
                 "-DENABLE_ECCODES=ON"
               ];

  buildInputs = [ cmake 
                  gfortran 
                  qt4
                  grib-api 
                  libemos 
                  eccodes 
                  magics
                ];

  enableParallelBuilding = true;

  meta = {
    description = "A meteorological workstation application";
    homepage    = https://software.ecmwf.int/wiki/display/METV/;
    platforms   = stdenv.lib.platforms.unix;
  };
}
