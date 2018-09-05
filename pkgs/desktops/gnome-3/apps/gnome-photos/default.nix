{ stdenv, gettext, fetchurl, libxml2, libgdata
, pkgconfig, gtk3, glib, tracker, tracker-miners
, itstool, gegl, babl, libdazzle, gfbgraph, grilo-plugins
, grilo, gnome-online-accounts
, desktop-file-utils, wrapGAppsHook
, gnome3, gdk_pixbuf, gexiv2, geocode-glib
, dleyna-renderer }:

let
  pname = "gnome-photos";
  version = "3.29.92";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "0p5h3k6wfkh7ddsyw2dyyymr90ynqm02hx5xgjqshqs3avxmi1lx";
  };

  # doCheck = true;

  nativeBuildInputs = [ pkgconfig gettext itstool libxml2 desktop-file-utils wrapGAppsHook ];
  buildInputs = [
    gtk3 glib gegl babl libgdata libdazzle
    gnome3.gsettings-desktop-schemas
    gdk_pixbuf gnome3.defaultIconTheme
    gfbgraph grilo-plugins grilo
    gnome-online-accounts tracker
    gexiv2 geocode-glib dleyna-renderer
    tracker-miners # For 'org.freedesktop.Tracker.Miner.Files' GSettings schema
  ];


  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Photos;
    description = "Access, organize and share your photos";
    maintainers = gnome3.maintainers;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
