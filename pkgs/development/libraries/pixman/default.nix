{ fetchurl, stdenv, pkgconfig, perl }:

stdenv.mkDerivation rec {
  name = "pixman-0.28.2";

  src = fetchurl {
    url = "http://cairographics.org/releases/${name}.tar.gz";
    sha256 = "0mcvxd5gx3w1wzgph91l2vaiic91jmx7s01hi2igphyvd80ckyia";
  };

  buildInputs = [ pkgconfig perl ];

  meta = {
    #homepage = http://poppler.freedesktop.org/;
    #description = "Poppler, a PDF rendering library";
    #license = "GPLv2";
  };
}
