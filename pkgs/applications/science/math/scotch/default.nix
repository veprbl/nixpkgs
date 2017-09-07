{ stdenv, fetchurl, bison, openmpi, flex, zlib}:

stdenv.mkDerivation rec {
  version = "6.0.4";
  name = "scotch-${version}";
  src_name = "scotch_${version}";

  buildInputs = [ bison openmpi flex zlib ];

  src = fetchurl {
    url = "http://gforge.inria.fr/frs/download.php/file/34618/${src_name}.tar.gz";
    sha256 = "f53f4d71a8345ba15e2dd4e102a35fd83915abf50ea73e1bf6efe1bc2b4220c7";
  };

  sourceRoot = "${src_name}/src";

  preConfigure = stdenv.lib.optionalString stdenv.isLinux ''
      ln -s Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    ln -s Make.inc/Makefile.inc.i686_mac_darwin10 Makefile.inc
    substituteInPlace Makefile.inc --replace gcc clang
  '' + ''
    substituteInPlace Makefile --replace "./include/*scotch*.h" "./include/*.h"
    substituteInPlace Makefile --replace "../lib/*scotch*$(LIB)" "../lib/*$(LIB)"
  '';

  installTargets = "ptesmumps install";

  installFlags = [ "prefix=\${out}" ];

  meta = {
    description = "Graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering";
    longDescription = ''
      Scotch is a software package for graph and mesh/hypergraph partitioning, graph clustering, 
      and sparse matrix ordering.
    '';
    homepage = http://www.labri.fr/perso/pelegrin/scotch;
    license = stdenv.lib.licenses.cecill-c;
    maintainers = [ stdenv.lib.maintainers.bzizou ];
    platforms = with stdenv.lib.platforms; linux ++ darwin;
  };
}

