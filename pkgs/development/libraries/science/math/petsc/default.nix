{ stdenv, fetchurl, python, gfortran, openblas, openmpi}:

with stdenv.lib;

let version = "3.7.2";

in stdenv.mkDerivation {
  name = "petsc-${version}";
  src = fetchurl {
    url = "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz";
    sha256 = "1v7h9k5hld65v9ci29q53x28zsr7yn4jx41d336xbq4pvz81ss1n";
  };

  buildInputs = [ python gfortran openblas openmpi ];

  configureFlags = [ "--with-64-bit-indices" ];

  doCheck = true;
  #checkTarget = "tests";

  meta = with stdenv.lib; {
    description = "Library for the solution of partial differential equations";
    license = licenses.bsd2;
    homepage = https://www.mcs.anl.gov/petsc;
    platforms = platforms.unix;
  };
}
