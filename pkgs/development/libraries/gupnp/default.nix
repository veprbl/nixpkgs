{ stdenv, fetchurl, meson, ninja, pkgconfig, gobject-introspection, vala, gtk-doc, docbook_xsl, docbook_xml_dtd_412, docbook_xml_dtd_44, glib, gssdp, libsoup, libxml2, libuuid }:

stdenv.mkDerivation rec {
  pname = "gupnp";
  version = "1.2.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${stdenv.lib.versions.majorMinor version}/gupnp-${version}.tar.xz";
    sha256 = "0911lv1bivsyv9wwdxm0i1w4r89j0vyyqp200gsfdnzk6v1a4x7x";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gobject-introspection vala gtk-doc docbook_xsl docbook_xml_dtd_412 docbook_xml_dtd_44 ];
  propagatedBuildInputs = [ glib gssdp libsoup libxml2 libuuid ];

  mesonFlags = [ "-Dgtk_doc=true" ];

  doCheck = true;

  meta = with stdenv.lib; {
    homepage = http://www.gupnp.org/;
    description = "An implementation of the UPnP specification";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
}
