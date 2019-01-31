{ stdenv, cmake, ninja, intltool, fetchurl, libxml2, webkitgtk, highlight
, pkgconfig, gtk3, glib, libnotify, gtkspell3
, wrapGAppsHook, itstool, shared-mime-info, libical, db, gcr, sqlite
, gnome3, librsvg, gdk_pixbuf, libsecret, nss, nspr, icu
, libcanberra-gtk3, bogofilter, gst_all_1, procps, p11-kit, openldap
, libmspack
 }:

let
  pname = "evolution-ews";
  version = "3.30.3";
in stdenv.mkDerivation rec {
  inherit pname version;
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "08k3p6fgj0mvvg62hpmz1hsd1rb9lxp34hxcsmwhjqsgxlyrdxib";
  };

  #propagatedUserEnvPkgs = [ gnome3.evolution-data-server gnome3.evolution ];

  buildInputs = [
    gtk3 glib gdk_pixbuf gnome3.defaultIconTheme librsvg db icu
    gnome3.evolution-data-server libsecret libical gcr
    webkitgtk shared-mime-info gnome3.gnome-desktop gtkspell3
    libcanberra-gtk3 bogofilter gnome3.libgdata sqlite
    gst_all_1.gstreamer gst_all_1.gst-plugins-base p11-kit
    nss nspr libnotify procps highlight gnome3.libgweather
    gnome3.gsettings-desktop-schemas
    gnome3.glib-networking openldap
    gnome3.evolution
    libmspack
  ];

  nativeBuildInputs = [ cmake ninja intltool itstool libxml2 pkgconfig wrapGAppsHook ];

  # TODO:
  # - [ ] fix install paths
  # - [ ] ensure evolution and other bits actually find what is installed!
  #postPatch = ''
  #  sed -i CMakeLists.txt -e 's,set(ewsdatadir.*,set(ewsdatadir "${placeholder "out"}/share/evolution-data-dir/ews"),'
  #'';
}

