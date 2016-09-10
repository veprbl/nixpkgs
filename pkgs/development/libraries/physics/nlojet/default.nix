{ stdenv, fetchurl, fetchpatch }:

stdenv.mkDerivation rec {
  name = "nlojet++";
  version = "4.1.3";

  src = fetchurl {
    url = "http://desy.de/~znagy/hep-programs/nlojet++/nlojet++-${version}.tar.gz";
    sha256 = "18qfn5kjzvnyh29x40zm2maqzfmrnay9r58n8pfpq5lcphdhhv8p";
  };

  patches = [
    (fetchpatch {
      url = "https://gist.githubusercontent.com/veprbl/e404103016ba819d580b/raw/917c57e8cb47b025b8eef1cf6d74174540fb3ccd/nlojet_clang_fix.patch";
      sha256 = "06pzmkvhiq073y48ay6mhwrbw7gj620sd2ab0z6qjkff3in7ljrc";
    })
  ];

  meta = {
    homepage = "http://www.desy.de/~znagy/Site/NLOJet++.html";
    description = "Implementation of calculation of the hadron jet cross sections";
    platforms = stdenv.lib.platforms.unix;
  };
}
