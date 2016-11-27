{ fetchurl, stdenv, cmake, gfortran, 
  openjpeg, libpng, netcdf, pythonPackages }:

stdenv.mkDerivation rec {
  name = "eccodes-${version}";
  version = "2.0.0";

  src = fetchurl {
    url = "https://software.ecmwf.int/wiki/download/attachments/45757960/eccodes-${version}-Source.tar.gz";
    sha256 = "1w343f2gas8ac9mv7f3cqnyjad3zw7x6zlm8g770m59qycfk32rk";
  };

  cmakeFlags = [ "-DENABLE_PNG=ON" 
                 "-DCMATH_PATH=${stdenv.libc}" # To ignore /usr/lib/libm.dylib on darwin
               ];

  buildInputs = [ cmake
                  gfortran
                  openjpeg
                  libpng
                  netcdf
                ];
  propagatedBuildInputs = with pythonPackages; [ 
                  python
                  numpy
                ];

  enableParallelBuilding = true;

  doCheck = false; # TODO: Fix tests

  meta = with stdenv.lib; {
    homepage = "https://software.ecmwf.int/wiki/display/ECC";
    license = licenses.asl20;
    description = "ECMWF Library for the GRIB, BUFR and GTS file formats";
    longDescription = ''
      An application program interface accessible from C, Fortran and Python
      programs developed for encoding and decoding WMO FM-92 GRIB, WMO FM-94
      BUFR and WMO GTS.
    '';
  };
}
