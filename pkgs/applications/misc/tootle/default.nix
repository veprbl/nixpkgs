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
    rev = "48a855481eafa14ccf20fb76bf914829344aa898";
    sha256 = "0cxiclpy5klawxq67bqvgcxkywj56ybkdxav9lzr2l4592c6a2yg";
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
