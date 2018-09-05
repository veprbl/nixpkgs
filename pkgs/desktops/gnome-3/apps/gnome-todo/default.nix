{ stdenv, fetchurl, meson, ninja, pkgconfig, python3, wrapGAppsHook
, gettext, gnome3, glib, gtk, libpeas
, gnome-online-accounts, gsettings-desktop-schemas
, evolution-data-server, libxml2, libsoup, libical, rest, json-glib }:

let
  pname = "gnome-todo";
  version = "3.91.1";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "02h6a3h3aavbh88if02m1d3n0cx841ag75wzvryjh4jvq8vgcwyy";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig gettext python3 wrapGAppsHook
  ];
  buildInputs = [
    glib gtk libpeas gnome-online-accounts
    gsettings-desktop-schemas gnome3.defaultIconTheme
    # Plug-ins
    evolution-data-server libxml2 libsoup libical
    rest json-glib
  ];

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    description = "Personal task manager for GNOME";
    homepage = https://wiki.gnome.org/Apps/Todo;
    license = licenses.gpl3Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
