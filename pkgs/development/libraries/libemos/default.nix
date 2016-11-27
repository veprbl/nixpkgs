{ stdenv, fetchurl, cmake, gfortran, eccodes, fftw }:

stdenv.mkDerivation rec{
  name = "libemos-${version}";
  version = "4.4.4";

  src = fetchurl {
    url = "https://software.ecmwf.int/wiki/download/attachments/3473472/libemos-${version}-Source.tar.gz";
    sha256 = "0wwray768rjrbamppaw1fil5m6qgkx863v65g1qx6w0jzgsp2kv0";
  };

  cmakeFlags = [ "-DENABLE_ECCODES=ON" ];

  buildInputs = [ cmake
                  gfortran
                  eccodes
                  fftw
                ];

  meta = with stdenv.lib; {
    homepage = https://software.ecmwf.int/wiki/display/EMOS/Emoslib;
    license = licenses.asl20;
    description = "ECMWF Library for interpolation and BUFR & CREX encoding/decoding";
    longDescription = ''
    The library includes interpolation software and BUFR & CREX
    encoding/decoding routines. It is used by the ECMWF meteorological
    archival and retrieval system (MARS) and also by the ECMWF workstation
    Metview.
    '';

  };
}

