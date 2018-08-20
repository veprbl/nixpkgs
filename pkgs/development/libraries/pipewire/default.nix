{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, doxygen, graphviz, valgrind
, glib, dbus, gst_all_1, v4l_utils, alsaLib, ffmpeg, libjack2, udev, libva, xorg
, sbc, SDL2, makeFontsConf, freefont_ttf, fetchpatch
}:

let
  version = "0.2.2";

  fontsConf = makeFontsConf {
    fontDirectories = [ freefont_ttf ];
  };
in stdenv.mkDerivation rec {
  name = "pipewire-${version}";

  src = fetchFromGitHub {
    owner = "PipeWire";
    repo = "pipewire";
    rev = version;
    sha256 = "1b19wdxwr07xifj58b91qqngj15n8c80nl9i8niaywk9ypxmwmpj";
  };

  outputs = [ "out" "dev" "doc" ];

  patches = [
    # Respect includedir properly
    (fetchpatch {
      url = https://github.com/PipeWire/pipewire/commit/90400b17d624369512007366eddb9996a3558d22.patch;
      sha256 = "0hfb60z162mkx6vrcrs08d1yav9nf5jhxay1f3qmrf5gib66ycwa";
    })
  ];

  nativeBuildInputs = [
    meson ninja pkgconfig doxygen graphviz valgrind
  ];
  buildInputs = [
    glib dbus gst_all_1.gst-plugins-base gst_all_1.gstreamer v4l_utils
    alsaLib ffmpeg libjack2 udev libva xorg.libX11 sbc SDL2
  ];

  mesonFlags = [
    "-Denable_docs=true"
    "-Denable_gstreamer=true"
  ];

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  FONTCONFIG_FILE = fontsConf; # Fontconfig error: Cannot load default config file

  doCheck = true;

  meta = with stdenv.lib; {
    description = "Server and user space API to deal with multimedia pipelines";
    homepage = https://pipewire.org/;
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jtojnar ];
  };
}
