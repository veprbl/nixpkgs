{ stdenv, fetchurl, aalib }:

stdenv.mkDerivation rec {
  name = "aview-${version}";
  version = "1.3.0rc1";

  src = fetchurl {
    url = "http://prdownloads.sourceforge.net/aa-project/${name}.tar.gz";
    sha256 = "16gcfi2a7akk1qq8pq2rv9z7vciwr2cfdp8zi2dbdfg8ji0irmj2";
  };

  buildInputs = [ aalib ];
}
