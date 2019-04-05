{ stdenv, fetchurl, meson, ninja, pkgconfig, gobject-introspection, vala, gtk-doc, docbook_xsl, docbook_xml_dtd_412, libsoup, gtk3, glib }:

stdenv.mkDerivation rec {
  pname = "gssdp";
  version = "1.2.0";

  outputs = [ "out" "bin" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1l80znxzzpb2fmsrjf3hygi9gcxx5r405qrk5430nbsjgxafzjr2";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gobject-introspection vala gtk-doc docbook_xsl docbook_xml_dtd_412 ];
  buildInputs = [ libsoup gtk3 ];
  propagatedBuildInputs = [ glib ];

  doCheck = true;

  mesonFlags = [ "-Dgtk_doc=true" ];

  meta = with stdenv.lib; {
    description = "GObject-based API for handling resource discovery and announcement over SSDP";
    homepage = http://www.gupnp.org/;
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
  };
}
