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
    rev = "963c9b0e44a5d61612b2c0908b316b20712539f5";
    sha256 = "1wjikc43pxx4zrjfw0q6zxikcgiicv4z8i8lwdjzgz2s9dc97npa";
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

