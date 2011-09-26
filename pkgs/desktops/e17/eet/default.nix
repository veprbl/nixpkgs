{ stdenv, fetchurl, pkgconfig, eina, zlib, libjpeg }:
stdenv.mkDerivation rec {
  name = "eet-${version}";
  version = "1.4.1";
  src = fetchurl {
    url = "http://download.enlightenment.org/releases/${name}.tar.gz";
    sha256 = "1hlznlmgkgzxnkmc3qgqjrc62bmwqj5af8lsh59vac2gf4jnymnc";
  };
  buildInputs = [ pkgconfig eina zlib libjpeg ];
  meta = {
    description = "Enlightenment's data encode/decode and storage library";
    longDescription = ''
      Enlightenment's EET is a tiny library designed to write an
      arbitary set of chunks of data to a file and optionally compress
      each chunk (very much like a zip file) and allow fast
      random-access reading of the file later on. EET files are
      perfect for storing data that is written once (or rarely) and
      read many times, especially when the program does not want to
      have to read all the data in at once.

      Use this library when you need to pack C structure and you want
      to retrieve it quickly with as few as possible memory use. You
      can also use it to serialize data quickly and exchange them
      between two program over ipc or network link.
    '';
    homepage = http://enlightenment.org/;
    license = stdenv.lib.licenses.bsd2;  # not sure
  };
}
