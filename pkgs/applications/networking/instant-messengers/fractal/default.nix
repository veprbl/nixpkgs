{ stdenv, fetchurl, fetchFromGitLab, meson, ninja, gettext, cargo, rustc, python3, rustPlatform, pkgconfig, gtksourceview
, hicolor-icon-theme, glib, libhandy, gtk3, dbus, openssl, sqlite, gst_all_1, wrapGAppsHook }:

#stdenv.mkDerivation rec {
rustPlatform.buildRustPackage rec {
  version = "3.99.1"; # beta
  name = "fractal-${version}";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "fractal";
    rev = "9a13a32f463cd0b0f7d5b02b1a97954100234345";
    sha256 = "0b1rhjp9fph82bx52fnhhm1p645dpclbdq4qqzqc2xbf4mcp3qbw";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig gettext cargo rustc python3 wrapGAppsHook
  ];
  buildInputs = [
    glib gtk3 libhandy dbus openssl sqlite gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad
   gtksourceview hicolor-icon-theme
  ];

  postPatch = ''
    patchShebangs scripts/meson_post_install.py
  '';

  # Don't use buildRustPackage phases, only use it for rust deps setup
  configurePhase = null;
  buildPhase = null;
  checkPhase = null;
  installPhase = null;

  cargoSha256 = "1cx68sndw573acszf0x56l6ghxy91w8mvwg223nlm54hcj32g4w1";

  meta = with stdenv.lib; {
    # TODO
    license = licenses.gpl3;
  };
}

