{ stdenv, fetchurl, cmake, libdigidoc, minizip, pcsclite, opensc, openssl
, xercesc, xml-security-c, pkgconfig, xsd, zlib, xalanc, xxd }:

stdenv.mkDerivation rec {
  version = "3.13.8";
  pname = "libdigidocpp";

  src = fetchurl {
     url = "https://github.com/open-eid/${pname}/releases/download/v${version}/${pname}-${version}.tar.gz";
     sha256 = "0lns9rkhjmvpmgvra12dk820r23yq00jzp4ycrl63w4k2x3i536z";
  };

  nativeBuildInputs = [ cmake pkgconfig xxd ];

  buildInputs = [
    libdigidoc minizip pcsclite opensc openssl xercesc
    xml-security-c xsd zlib xalanc
  ];

  meta = with stdenv.lib; {
    description = "Library for creating DigiDoc signature files";
    homepage = http://www.id.ee/;
    license = licenses.lgpl2;
    platforms = platforms.linux;
    maintainers = [ maintainers.jagajaga ];
  };
}
