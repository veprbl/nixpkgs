{ fetchurl, stdenv, pkgconfig, cmake, gfortran, 
  proj, boost, pango, expat,
  eccodes, libemos, swig, qt4, 
  netcdf, netcdfcxx4legacy, netcdffortran,
  libgeotiff, pythonPackages }:

stdenv.mkDerivation rec {
  name = "Magics-${version}";
  version = "2.29.6";

  src = fetchurl {
    url = "https://software.ecmwf.int/wiki/download/attachments/3473464/Magics-${version}-Source.tar.gz";
    sha256 = "1nx23197ljp73h1ls6rw6c8fhia5y54h7znjldllcg42ppiabkw8";
  };

  preConfigure = ''
    echo "Patching Netcdf.h for case-insensitive filesystems"
    for f in ./src/decoders/*; do
      substituteInPlace $f --replace "Netcdf.h" "NetcdfMain.h"
    done
    mv src/decoders/Netcdf.h src/decoders/NetcdfMain.h
    '';

  cmakeFlags = [ 
    "-DENABLE_ECCODES=ON" 
    "-DENABLE_BUFR=ON"
    "-DENABLE_METVIEW=ON"
  ];

  buildInputs = [ 
    cmake
    pkgconfig # just for FindPangoCairo.cmake
    gfortran
    proj
    boost
    pango
    expat
    eccodes
    libemos
    swig
    qt4
    netcdf
    netcdfcxx4legacy # TODO: Does not work yet, because of case insensitive OS X and magics has "Netcdf.h". DUMB!!!
    netcdffortran
    libgeotiff
  ];

  propagatedBuildInputs = with pythonPackages; [ 
    python
    numpy
  ];

  enableParallelBuilding = true;

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = "https://software.ecmwf.int/wiki/display/MAGP";
    license = licenses.asl20;
    description = "ECMWF Library for plotting meteorological data";
  };
}
