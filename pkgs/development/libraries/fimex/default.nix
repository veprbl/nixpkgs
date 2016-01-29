{ fetchurl, stdenv,
  libxml2, boost, proj, udunits, expat,
  netcdf, grib-api, postgresql, log4cpp, gfortran, R,
  curl, hdf5, jasper
}:

stdenv.mkDerivation rec{
  name = "fimex-${version}";
  version = "0.61.1";

  src = fetchurl {
    url = https://wiki.met.no/_media/fimex/fimex-0.61.1.tar.gz; 
    sha256 = "0kiq4m0hfd8ywb12c45fjdmjpn6jpkhijz0cbz83f8v1gnri81w5";
  };
  
  configureFlags = [ "--with-boost-libdir=${boost.lib}/lib" 
                     "--with-boost-incdir=${boost.dev}/include"
                     "--enable-openmp"
                     "--enable-log4cpp"
                     "--enable-fortran"
                   ];         

  buildInputs = [ libxml2
                  boost
                  proj
                  udunits
                  expat
                  netcdf
                  grib-api
                  postgresql
                  log4cpp
                  gfortran
                  curl
                  hdf5
                  jasper
                ];
  doCheck = false; # TODO: Make boost test linking work

  meta = with stdenv.lib; {
    homepage = "https://wiki.met.no/fimex";
    license = licenses.lgpl21Plus;
    description = "MET Norway library for gridded geospatial data.";
    longDescription = ''
      Fimex is a the File Interpolation, Manipulation and EXtraction library
      for gridded geospatial data, written in C/C++. It converts between
      different, extensible dataformats (currently netcdf, NcML, grib1/2 and
      felt). It enables you to change the projection and interpolation of
      scalar and vector grids. It makes it possible to subset the gridded
      data and to extract only parts of the files.  
    '';

  };
}

