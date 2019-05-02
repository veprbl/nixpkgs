{ stdenv
, fetchurl
, fetchpatch
, meson
, ninja
, pkgconfig
, gobject-introspection
, vala
, gtk-doc
, docbook_xsl
, docbook_xml_dtd_412
, docbook_xml_dtd_44
, glib
, gssdp
, libsoup
, libxml2
, libuuid
, gnome3
}:

stdenv.mkDerivation rec {
  pname = "gupnp";
  version = "1.2.1";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0pjz65x128qhjlzqss17z27rfai05w9apl4rb7h9hma1zxz5bam9";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    gobject-introspection
    vala
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_412
    docbook_xml_dtd_44
  ];

  buildInputs = [
    libuuid
  ];

  propagatedBuildInputs = [
    glib
    gssdp
    libsoup
    libxml2
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    homepage = http://www.gupnp.org/;
    description = "An implementation of the UPnP specification";
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
}
