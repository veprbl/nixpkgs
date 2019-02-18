{ stdenv, fetchurl, fetchFromGitHub, intltool, itstool, pkgconfig, gtk3, vala_0_40, enchant
, wrapGAppsHook, gdk_pixbuf, meson, ninja, desktop-file-utils, python3
, libnotify, libcanberra-gtk3, libsecret, gmime, isocodes
, gobject-introspection, libpthreadstubs, sqlite, gcr, json-glib, enchant2, libunwind
, gnome3, librsvg, gnome-doc-utils, webkitgtk, fetchpatch }:

let
  pname = "geary";
  version = "0.13.0";
in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "0zxy7mixnjsjlv8718r5q2vh9hr96v5pqvjf28y652v7a6lbrnag";
  };

  nativeBuildInputs = [ vala_0_40 intltool itstool pkgconfig wrapGAppsHook meson ninja desktop-file-utils gnome-doc-utils gobject-introspection python3 ];
  buildInputs = [
    gtk3 enchant webkitgtk libnotify libcanberra-gtk3 gnome3.libgee libsecret gmime sqlite
    libpthreadstubs gnome3.gsettings-desktop-schemas gcr isocodes json-glib enchant2 libunwind
    gdk_pixbuf librsvg gnome3.defaultIconTheme gnome3.gnome-online-accounts gnome3.glib-networking
  ];

  postPatch = ''
    chmod +x build-aux/post_install.py # patchShebangs requires executable file
    patchShebangs build-aux/post_install.py
  '';

  preFixup = ''
    # Add geary to path for geary-attach
    gappsWrapperArgs+=(--prefix PATH : "$out/bin")
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
    license = licenses.lgpl2;
    platforms = platforms.linux;
  };
}
