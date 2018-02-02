{ fetchurl, stdenv, meson, ninja, gtk3, libexif, libgphoto2, libsoup, libxml2, vala, sqlite
, webkitgtk, pkgconfig, gnome3, gst_all_1, libgudev, libraw, glib, json_glib
, gettext, desktop_file_utils, gdk_pixbuf, librsvg, wrapGAppsHook
, itstool, libgdata }:

# for dependencies see https://wiki.gnome.org/Apps/Shotwell/BuildingAndInstalling

stdenv.mkDerivation rec {
  version = "${major}.${minor}";
  major = "0.27";
  minor = "3";
  name = "shotwell-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/shotwell/${major}/${name}.tar.xz";
    sha256 = "1jacan61l3dci5rix0b8f16k3cbhck2s80b1d4bzarh3x34w4yza";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig itstool gettext desktop_file_utils wrapGAppsHook
  ];

  buildInputs = [
    gtk3 libexif libgphoto2 libsoup libxml2 vala sqlite webkitgtk
    gst_all_1.gstreamer gst_all_1.gst-plugins-base gnome3.libgee
    libgudev gnome3.gexiv2 gnome3.gsettings_desktop_schemas
    libraw json_glib glib gdk_pixbuf librsvg gnome3.rest
    gnome3.gcr gnome3.defaultIconTheme libgdata
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  meta = with stdenv.lib; {
    description = "Popular photo organizer for the GNOME desktop";
    homepage = https://wiki.gnome.org/Apps/Shotwell;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [domenkozar];
    platforms = platforms.linux;
  };
}
