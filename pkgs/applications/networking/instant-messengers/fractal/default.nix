{ stdenv, fetchurl, fetchFromGitLab, meson, ninja, gettext, cargo, rustc, python3, rustPlatform, pkgconfig, gtksourceview
, hicolor-icon-theme, glib, libhandy, gtk3, dbus, openssl, sqlite, gst_all_1, wrapGAppsHook }:

#stdenv.mkDerivation rec {
rustPlatform.buildRustPackage rec {
  version = "3.30.0-git";
  name = "fractal-${version}";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "fractal";
    rev = "408f3da4ac394538eb4c54a7c7fcdf54b56a404d";
    sha256 = "18z2dqyqnyj1i65msw4hml7xzyi7n59hb7rzdffn58sf7bwvhsfr";
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

  cargoSha256 = "15yfh7wvj95g47i777sgxz7zc4xcx6frmpi82ywjgj58fzwndjsg";

  meta = with stdenv.lib; {
    # TODO
    license = licenses.gpl3;
  };
}

