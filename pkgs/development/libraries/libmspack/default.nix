{stdenv, fetchurl}:

stdenv.mkDerivation rec {
  name = "libmspack-0.9.1alpha";

  src = fetchurl {
    url = "https://www.cabextract.org.uk/libmspack/${name}.tar.gz";
    sha256 = "0h1f5w8rjnq7dcqpqm1mpx5m8q80691kid6f7npqlqwqqzckd8v2";
  };

  meta = {
    description = "A de/compression library for various Microsoft formats";
    homepage = https://www.cabextract.org.uk/libmspack;
    license = stdenv.lib.licenses.lgpl2;
    platforms = stdenv.lib.platforms.unix;
  };
}
