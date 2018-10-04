{ fetchurl, stdenv, fetchgit, fetchpatch, intltool, meson, ninja, pkgconfig, gtk-doc, docbook_xsl, docbook_xml_dtd_412, glib, json-glib, libsoup, libnotify, gdk_pixbuf
, modemmanager, avahi, glib-networking, wrapGAppsHook, gobjectIntrospection
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "geoclue-${version}";
  version = "2018-09-30";

  src = fetchgit {
    url = https://gitlab.freedesktop.org/geoclue/geoclue;
    rev = "acd253dcc61d0b69dc6aa345ad4f148038c26290";
    sha256 = "0ipqnl08c9s7ylq52mnfgpy9xkwi8360c8qqlai9cwnw1n96c42i";
  };
  #src = fetchurl {
  #  url = "https://www.freedesktop.org/software/geoclue/releases/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
  #  sha256 = "1jnad1f3rf8h05sz1lc172jnqdhqdpz76ff6m7i5ss3s0znf5l05";
  #};

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [
    meson ninja
    pkgconfig intltool wrapGAppsHook gobjectIntrospection
    # devdoc
    gtk-doc docbook_xsl docbook_xml_dtd_412
  ];

  buildInputs = [
    glib json-glib libsoup avahi
    libnotify gdk_pixbuf
  ] ++ optionals (!stdenv.isDarwin) [ modemmanager ];

  propagatedBuildInputs = [ glib glib-networking ];

#  configureFlags = [
#    "--with-systemdsystemunitdir=$(out)/etc/systemd/system"
#    "--enable-introspection"
#    "--enable-gtk-doc"
#    "--enable-demo-agent=${if withDemoAgent then "yes" else "no"}"
#  ] ++ optionals stdenv.isDarwin [
#    "--disable-silent-rules"
#    "--disable-3g-source"
#    "--disable-cdma-source"
#    "--disable-modem-gps-source"
#    "--disable-nmea-source"
#  ];

  meta = with stdenv.lib; {
    description = "Geolocation framework and some data providers";
    homepage = https://gitlab.freedesktop.org/geoclue/geoclue/wikis/home;
    maintainers = with maintainers; [ raskin garbas ];
    platforms = with platforms; linux ++ darwin;
    license = licenses.lgpl2;
  };
}
