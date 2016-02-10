{ stdenv, fetchurl, cmake, netcdf, gfortran }:
stdenv.mkDerivation rec {
  name = "netcdf-fortran-${version}";
  version = "4.4.3";

  src = fetchurl {
    url = "https://github.com/Unidata/netcdf-fortran/archive/v${version}.tar.gz";
    sha256 = "1679whjf1d5v6w6y0vjzbwc269jlfficc5bj64p25s4yih0zqw21";
  };

  buildInputs = [ cmake
                  netcdf 
                  gfortran
                ];

  doCheck = true;
  checkTarget = "test";

  meta = {
    description = "Fortran API to manipulate netcdf files";
    homepage = "http://www.unidata.ucar.edu/software/netcdf/";
    license = stdenv.lib.licenses.free;
  };
}
