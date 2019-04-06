{ stdenv
, fetchurl
, fetchpatch
, meson
, ninja
, pkgconfig
, python3
, wrapGAppsHook
, gettext
, gnome3
, glib
, gtk3
, libpeas
, gnome-online-accounts
, gsettings-desktop-schemas
, adwaita-icon-theme
, evolution-data-server
, libxml2
, libsoup
, libical
, librest
, json-glib
}:

stdenv.mkDerivation rec {
  pname = "gnome-todo";
  version = "3.91.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "02h6a3h3aavbh88if02m1d3n0cx841ag75wzvryjh4jvq8vgcwyy";
  };

  patches = [
    # fix build with e-d-s 3.32
    (fetchpatch {
      url = https://gitlab.gnome.org/GNOME/gnome-todo/commit/6cdabc4dd0c6c804a093b94c269461ce376fed4f.patch;
      sha256 = "08ldgyxv9216dgr8y9asqd7j2y82y9yqnqhkqaxc9i8a67yz1gzy";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkgconfig
    gettext
    python3
    wrapGAppsHook
  ];

  buildInputs = [
    glib
    gtk3
    libpeas
    gnome-online-accounts
    gsettings-desktop-schemas
    gnome3.adwaita-icon-theme
    # Plug-ins
    evolution-data-server
    libxml2
    libsoup
    libical
    librest
    json-glib
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  postPatch = ''
    chmod +x build-aux/meson/meson_post_install.py
    patchShebangs build-aux/meson/meson_post_install.py
  '';


  meta = with stdenv.lib; {
    description = "Personal task manager for GNOME";
    homepage = https://wiki.gnome.org/Apps/Todo;
    license = licenses.gpl3Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
