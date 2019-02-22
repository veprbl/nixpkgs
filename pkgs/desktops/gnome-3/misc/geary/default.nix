{ stdenv, fetchurl, intltool, pkgconfig, gtk3, vala_0_40, enchant
, wrapGAppsHook, gdk_pixbuf, cmake, ninja, desktop-file-utils
, libnotify, libcanberra-gtk3, libsecret, gmime, isocodes
, gobject-introspection, libpthreadstubs, sqlite, gcr, libgee
, gsettings-desktop-schemas, adwaita-icon-theme
, gnome3, librsvg, gnome-doc-utils, webkitgtk, fetchpatch }:

stdenv.mkDerivation rec {
  pname = "geary";
  version = "0.13.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0h9pf2mdskq7mylib1m9hw86nwfmdzyngjl7ywangqipm1k5svjx";
  };

  nativeBuildInputs = [
    desktop-file-utils gettext gobject-introspection itstool
    libxml2 meson ninja pkgconfig vala wrapGAppsHook python3
  ];

  buildInputs = [
    gtk3 enchant webkitgtk libnotify libcanberra-gtk3 libgee libsecret gmime sqlite
    libpthreadstubs gsettings-desktop-schemas gcr isocodes
    gdk_pixbuf librsvg adwaita-icon-theme
  ];

  checkInputs = [ xvfb_run dbus ];

  mesonFlags = [
    "-Dcontractor=true" # install the contractor file (Pantheon specific)
  ];

  postPatch = ''
    chmod +x build-aux/post_install.py
    patchShebangs build-aux/post_install.py
  '';

  preFixup = ''
    # Add geary to path for geary-attach
    gappsWrapperArgs+=(--prefix PATH : "$out/bin")
  '';

  doCheck = true;

  checkPhase = ''
    NO_AT_BRIDGE=1 \
    XDG_DATA_DIRS=:$XDG_DATA_DIRS:${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${shared-mime-info}/share \
    xvfb-run -s '-screen 0 800x600x24' dbus-run-session \
      --config-file=${dbus.daemon}/share/dbus-1/session.conf \
      meson test -v --no-stdsplit
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Geary;
    description = "Mail client for GNOME 3";
    maintainers = gnome3.maintainers;
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
