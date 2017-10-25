{ stdenv, lib, fetchurl, pkgconfig, gtk3, itstool, gst_all_1, libxml2, libnotify
, libcanberra_gtk3, intltool, makeWrapper, dvdauthor, libburn, libisofs
, vcdimager, wrapGAppsHook, hicolor_icon_theme }:

stdenv.mkDerivation rec {
  version = "0.2";
  name = "iso-image-writer-${version}";

  src = fetchurl {
    url = "https://download.kde.org/unstable/isoimagewriter/0.2/isoimagewriter-0.2.tar.xz";
    sha256 = "0475r2qq8jzpd9wb4fx43n2plbnwq4mfbfhcaq5h8md3nm3h5gva";
  };

  nativeBuildInputs = [];

  buildInputs = [];

  # configureFlags = [
  #   "--with-girdir=$out/share/gir-1.0"
  #   "--with-typelibdir=$out/lib/girepository-1.0"
  # ];

  # preFixup = ''
  #   gappsWrapperArgs+=(--prefix PATH : "${binpath}" --prefix GST_PLUGIN_SYSTEM_PATH : "$GST_PLUGIN_SYSTEM_PATH")
  # '';

  meta = with stdenv.lib; {
    description = "A tool to write a .iso file to a USB disk";
    homepage = https://community.kde.org/ISOImageWriter;
    maintainers = [ maintainers.jluttine ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
