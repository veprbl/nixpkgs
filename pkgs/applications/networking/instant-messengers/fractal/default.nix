{ stdenv, fetchurl, fetchFromGitLab, meson, ninja, gettext, cargo, rustc, python3, rustPlatform, pkgconfig, gtksourceview
, glib, libhandy, gtk3, dbus, openssl, sqlite, gst_all_1, wrapGAppsHook }:

#stdenv.mkDerivation rec {
rustPlatform.buildRustPackage rec {
  version = "3.30.0-git";
  name = "fractal-${version}";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "World";
    repo = "fractal";
    rev = "371965b79769e90235f1a50384ffcbdfa1015499";
    sha256 = "1126qcdg0h8sk3kganwzzzid426nhwsv269cczgwiiny3fpz99pc";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig gettext cargo rustc python3 wrapGAppsHook
  ];
  buildInputs = [
    glib gtk3 libhandy dbus openssl sqlite gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad
   gtksourceview
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

