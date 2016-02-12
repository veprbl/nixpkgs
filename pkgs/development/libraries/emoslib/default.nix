{ fetchurl, stdenv, cmake, gfortran, grib-api
}:

stdenv.mkDerivation rec{
  name = "emoslib-${version}";
  version = "4.0.7";

  src = fetchurl {
    url = https://software.ecmwf.int/wiki/download/attachments/3473472/libemos-4.0.7-Source.tar.gz;
    sha256 = "1jiha84qif47fwcf3qnxkyssgwncxarh8p2ic5gz4qaaimcz45qy";
  };
  
  configureFlags = [ 
                   ];         

  buildInputs = [ 
                  cmake
                  gfortran
                  grib-api
                ];

  checkTarget = "test";

  doCheck = true; # TODO: Make boost test linking work

  meta = with stdenv.lib; {
    homepage = "https://software.ecmwf.int/wiki/display/EMOS/Emoslib";
    license = licenses.lgpl21Plus;
    description = "ECMWF interpolation and BUFR/CREX encoding/decoding.";
    longDescription = 
    ''
    The Interpolation library (EMOSLIB) includes Interpolation
    software and BUFR & CREX encoding/decoding routines. It is used by the
    ECMWF meteorological archival and retrieval system (MARS) and also by
    the ECMWF workstation Metview.
    '';

  };
}

