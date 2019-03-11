{ stdenv, fetchFromGitHub
, meson, ninja, pkgconfig, python3, libgee, gsettings-desktop-schemas
, gnome3, pantheon, gobject-introspection, wrapGAppsHook, vala
, gtk3, json-glib, glib, glib-networking, hicolor-icon-theme
}:

stdenv.mkDerivation rec {
  pname = "tootle";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "bleakgrey";
    repo = pname;
    #rev = version;
    rev = "4862438e15b074d8d2e3c23699ebeadac7ae36fe";
    sha256 = "1q17r4cjfckr918fpgpa1rf0cfmcbwv42js3s41dqkly77lw7d4s";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkgconfig
    python3
    vala
    wrapGAppsHook
  ];
  buildInputs = [
    gtk3 pantheon.granite json-glib glib glib-networking hicolor-icon-theme
    libgee gnome3.libsoup gsettings-desktop-schemas
  ];

  postPatch = ''
    chmod +x ./meson/post_install.py
    patchShebangs ./meson/post_install.py
  '';

  meta = with stdenv.lib; {
    description = "Simple Mastodon client designed for elementary OS";
    homepage    = https://github.com/bleakgrey/tootle;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ dtzWill ];
  };
}
