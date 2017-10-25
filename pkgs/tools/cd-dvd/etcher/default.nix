{ stdenv, lib, fetchurl, pkgconfig, gtk3, itstool, gst_all_1, libxml2, libnotify
, libcanberra_gtk3, intltool, makeWrapper, dvdauthor, libburn, libisofs
, vcdimager, wrapGAppsHook, hicolor_icon_theme }:

stdenv.mkDerivation rec {
  version = "1.1.2";
  name = "etcher-${version}";

  src = fetchurl {
    url = "https://github.com/resin-io/etcher/archive/v1.1.2.tar.gz";
    sha256 = "06v436g00v6gzbzr6p7jzwjmv4m064n7id09fhya79v8vpb7z9av";
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
    description = "Write OS ISO images to SD cards and USB drives, safely and easily";
    homepage = https://etcher.io/;
    maintainers = [ maintainers.jluttine ];
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
