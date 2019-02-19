{ stdenv, fetchurl, autoconf, automake, gettext, libtool, pkgconfig
, gfortran, openblas, eigen }:

with stdenv.lib;

let
  version = "3.7.0";
in
stdenv.mkDerivation {
  name = "arpack-${version}";

  src = fetchurl {
    url = "https://github.com/opencollab/arpack-ng/archive/${version}.tar.gz";
    sha256 = "1mn27kx683lp0vxlz79i95jhsp2i0zyzd6vwfdd6p78brp1kyblp";
  };

  nativeBuildInputs = [ autoconf automake gettext libtool pkgconfig ];
  buildInputs = [ gfortran openblas eigen ];

  doCheck = true;

  BLAS_LIBS = "-L${openblas}/lib -lopenblas";

  INTERFACE64 = optional openblas.blas64 "1";

  preConfigure = ''
    ./bootstrap
  '';

  meta = {
    homepage = https://github.com/opencollab/arpack-ng;
    description = ''
      A collection of Fortran77 subroutines to solve large scale eigenvalue
      problems.
    '';
    license = stdenv.lib.licenses.bsd3;
    maintainers = [ stdenv.lib.maintainers.ttuegel ];
    platforms = stdenv.lib.platforms.unix;
  };
}
