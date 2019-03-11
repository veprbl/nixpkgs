{ stdenv, fetchurl, xalanc, xercesc, openssl, pkgconfig }:

stdenv.mkDerivation rec {
  pname = "xml-security-c";
  version = "2.0.2";

  src = fetchurl {
    url = "https://www.apache.org/dist/santuario/c-library/${pname}-${version}.tar.bz2";
    sha256 = "39e963ab4da477b7bda058f06db37228664c68fe68902d86e334614dd06e046b";
  };

  postPatch = ''
    mkdir -p xsec/yes/lib
    sed -i -e 's/-O2 -DNDEBUG/-DNDEBUG/g' configure
  '';

  configureFlags = [
    "--with-openssl"
    "--with-xerces"
    "--with-xalan"
    "--disable-static"
  ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ xalanc xercesc openssl ];

  meta = {
    homepage = http://santuario.apache.org/;
    description = "C++ Implementation of W3C security standards for XML";
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.jagajaga ];
  };
}
