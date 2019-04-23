{ appimageTools, fetchurl, lib, gsettings-desktop-schemas, gtk3 }:

let
  pname = "joplin-desktop";
  version = "1.0.143";
in appimageTools.wrapType2 rec {
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}-x86_64.AppImage";
    sha256 = "1waglwxpr18a07m7ix9al6ac4hrdqzzqmy1qgp45b922nbkw9g10";
  };


  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  multiPkgs = null; # no 32bit needed
  # TODO: refactor so this isn't a huge copy from appimageTools
  extraPkgs = p: with p; [
    desktop-file-utils
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-ugly
    libdrm
    xorg.xkeyboardconfig
    xorg.libpciaccess

    glib
    gtk2
    bzip2
    zlib
    gdk_pixbuf

    xorg.libXinerama
    xorg.libXdamage
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXxf86vm
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
    freetype
    (curl.override { gnutlsSupport = true; sslSupport = false; })
    nspr
    nss
    fontconfig
    cairo
    pango
    expat
    dbus
    cups
    libcap
    SDL2
    libusb1
    udev
    dbus-glib
    libav
    atk
    at-spi2-atk
    libudev0-shim
    networkmanager098

    xorg.libXt
    xorg.libXmu
    xorg.libxcb
    libGLU
    libuuid
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
    openssl
    libidn
    tbb
    wayland
    mesa_noglu
    libxkbcommon

    flac
    freeglut
    libjpeg
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    gstreamer
    gst-plugins-base
    libappindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
    libvdpau
    alsaLib

    harfbuzz
    e2fsprogs
    libgpgerror
    keyutils.lib
    libjack2
    fribidi

    # libraries not on the upstream include list, but nevertheless expected
    # by at least one appimage
    libtool.lib # for Synfigstudio
  ];

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
  '';

  meta = with lib; {
    description = "An open source note taking and to-do application with synchronisation capabilities";
    longDescription = ''
      Joplin is a free, open source note taking and to-do application, which can
      handle a large number of notes organised into notebooks. The notes are
      searchable, can be copied, tagged and modified either from the
      applications directly or from your own text editor. The notes are in
      Markdown format.
    '';
    homepage = https://joplin.cozic.net/;
    license = licenses.mit;
    maintainers = with maintainers; [ rafaelgg raquelgb ];
    platforms = [ "x86_64-linux" ];
  };
}
