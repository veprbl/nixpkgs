{ stdenv, fetchFromGitHub, autoconf, automake, libtool, pkgconfig, which, libxslt, libxml2, docbook_xml_dtd_412, docbook_xsl, glib, imagemagick, darwin }:


stdenv.mkDerivation rec{
  version = "1.1.0-unstable";
  pname = "chafa";

  src = fetchFromGitHub {
    owner = "hpjansson";
    repo = "chafa";
    #rev = version;
    rev = "294da216933ba8c41570d3678d48ad4d59b54058";
    sha256 = "18p1q2qka93hgkgyi1x1hismr9bypbjh095fs9b5l06i00vb6k8z";
  };

  nativeBuildInputs = [ autoconf
                        automake
                        libtool
                        pkgconfig
                        which
                        libxslt
                        libxml2
                        docbook_xml_dtd_412
                        docbook_xsl
                      ];

  buildInputs = [ glib imagemagick ] ++ stdenv.lib.optional stdenv.isDarwin [ darwin.apple_sdk.frameworks.ApplicationServices ];

  patches = [ ./xmlcatalog_patch.patch ];

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [ "--enable-man"
                     "--with-xml-catalog=${docbook_xml_dtd_412}/xml/dtd/docbook/catalog.xml"
                   ];

  meta = with stdenv.lib; {
    description = "Terminal graphics for the 21st century.";
    homepage = https://hpjansson.org/chafa/;
    license = licenses.lgpl3Plus;
    platforms = platforms.all;
    maintainers = [ maintainers.mog ];
  };
}
