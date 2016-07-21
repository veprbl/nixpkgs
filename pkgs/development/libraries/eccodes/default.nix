{ fetchurl, stdenv, netcdf
, cmake
, curl # for checkPhase
, enableJPEG ? true, jasper
, enablePython ? true, python, numpy
, enableFortran ? true, gfortran
, enableECCThreads ? true # TODO
, enableOMPThreads ? false # TODO
}:

assert !enableECCThreads || !enableOMPThreads;


stdenv.mkDerivation rec{
  name = "eccodes-${version}";
  version = "0.16.0";

  src = fetchurl {
    url = "https://software.ecmwf.int/wiki/download/attachments/45757960/eccodes-${version}-Source.tar.gz";
    sha256 = "1qznn5fhcc7wpx6498l2y81nm1vcnmhvcnmpzmwccp26rgpxvjyf";
  };

  patches = [ ./ignore-cmath.patch ]; # Darwin-only problem with impure paths?

  buildInputs = with stdenv.lib; [ cmake netcdf ]
    ++ optional enableJPEG jasper
    ++ optional enableFortran gfortran
    ++ optional enablePython [ python numpy ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = https://software.ecmwf.int/wiki/display/ECC;
    license = licenses.asl20;
    description = "ECMWF Library for the GRIB, BUFR and GTS file formats";

  };
}

