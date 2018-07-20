{ stdenv, fetchurl, file, zlib }:

stdenv.mkDerivation rec {
  name = "file-${version}";
  version = "5.33";

  src = fetchurl {
    urls = [
      "ftp://ftp.astron.com/pub/file/${name}.tar.gz"
      "https://distfiles.macports.org/file/${name}.tar.gz"
    ];
    sha256 = "1iipnwjkag7q04zjkaqic41r9nlw0ml6mhqian6qkkbisb1whlhw";
  };

  nativeBuildInputs = stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) file;
  buildInputs = [ zlib ];

  patches = [ ./file-5.33-CVE-2018-10360.patch ];

  doCheck = true;


  meta = with stdenv.lib; {
    homepage = http://darwinsys.com/file;
    description = "A program that shows the type of files";
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}
