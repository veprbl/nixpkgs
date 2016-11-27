{ stdenv, fetchurl, netcdf, hdf5, curl }:
stdenv.mkDerivation rec {
  name = "netcdf-cxx4-${version}";
  version = "4.2";

  src = fetchurl {
    url = "ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-cxx-4.2.tar.gz";
    sha256 = "1lfcf849lk1yg8rhh345pabfm92wrfm48kmcbqjh3q0fkas6mvcm";
  };

  buildInputs = [ netcdf hdf5 curl ];
  doCheck = true;

  meta = {
    description = "Legacy C++ API to manipulate netcdf files";
    homepage = "http://www.unidata.ucar.edu/software/netcdf/";
    license = stdenv.lib.licenses.free;
    platforms = stdenv.lib.platforms.unix;
  };
}
