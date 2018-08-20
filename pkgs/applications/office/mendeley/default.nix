/*{ fetchurl, stdenv, dpkg, which
, makeWrapper
, alsaLib
, desktop-file-utils
, dbus
, libcap
, fontconfig
, freetype
, gcc
, gconf
, glib
, icu
, libxml2
, libxslt
, orc
, python
, nss
, nspr
, qtbase
, qtsvg
, qtdeclarative
, qtwebchannel
, qtquickcontrols
, qtwebkit
, qtwebengine
, qtstyleplugins
, full
, sqlite
, xorg
, zlib
# The provided wrapper does this, but since we don't use it
# we emulate the behavior.  The downside is that this
# will leave entries on your system after uninstalling mendeley.
# (they can be removed by running '$out/bin/install-mendeley-link-handler.sh -u')
, autorunLinkHandler ? true
# Update script
, writeScript
}:
*/

{ stdenv, fetchurl, buildFHSUserEnv, dpkg, runtimeShell, runCommand
, python
, gconf
#, alsaLib
#, desktop-file-utils
#, dbus
#, libcap
#, fontconfig
#, freetype
#, gcc
#, gconf
#, glib
#, icu
#, libxml2
#, libxslt
#, mesa_noglu
#, orc
#, python
#, nss
}:

let
  arch32 = "i686-linux";

  arch = if stdenv.system == arch32
    then "i386"
    else "amd64";

  shortVersion = "1.19.2-stable";

  version = "${shortVersion}_${arch}";

  #url = "http://desktop-download.mendeley.com/download/apt/pool/main/m/mendeleydesktop/mendeleydesktop_${version}.deb";
  url = "http://desktop-download.mendeley.com/download/apt/pool/main/m/mendeleydesktop/mendeleydesktop_${version}.deb";
  sha256 = if stdenv.system == arch32
    then "11zh9dckj3krbj64ap1am6phhjj18595d1i8gdq81z13arxhg1m5"
    else "07apz68sc4k2nl3cvhxrj9rdfra2klnjx64k2ppayvggl4nb6lzh";


mendeleySrc = stdenv.mkDerivation rec {
  inherit version;
  name = "mendeley-${version}-pkg";

  src = fetchurl {
    url = url;
    sha256 = sha256;
  };

  nativeBuildInputs = [ dpkg ];

  buildInputs = [ python ];

  unpackPhase = ":";

  installPhase = ''
    dpkg-deb -x $src $out
  '';
};

fhsEnv = buildFHSUserEnv {
  name = "mendeley-fhs-env";
  targetPkgs = pkgs: with pkgs; with xorg; [
    which
    xdg_utils
    xorg.xrandr
    python2
    gnome3.zenity
    bashInteractive
    gtk3
    iana-etc
    #qt5.full
    #gtk3 dbus-glib
    #xorg.libX11
    #xorg.xcbutilkeysyms
    #xorg.libxcb
    #xorg.libXcomposite
    #xorg.libXext
    #xorg.libXrender
    #xorg.libXi
    #xorg.libXcursor
    #xorg.libXtst
    #xorg.libXrandr
    #xorg.xcbutilimage

    #qtbase
    #qtsvg
    #qtdeclarative
    #qtwebchannel
    #qtquickcontrols
    #qtwebkit
    #qtwebengine
    #qtstyleplugins
    #full
    alsaLib
    dbus
    freetype
    fontconfig
    gcc.cc
    gconf
    glib
    icu
    libcap
    libxml2
    libxslt
    nspr
    nss
    orc
    sqlite
    xorg.libX11
    xorg.xcbutilkeysyms
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    xorg.xcbutilimage

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

    zlib

    libGL
    libdrm
    libGLU
    mesa_noglu

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
  ];
  runScript = "${mendeleySrc}/usr/bin/mendeleydesktop";
};

  meta = with stdenv.lib; {
    homepage = http://www.mendeley.com;
    description = "A reference manager and academic social network";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers  = with maintainers; [ dtzWill ];
  };

  in fhsEnv
#in runCommand "mendeley-${version}" { inherit meta; } ''
#  mkdir -p $out/bin $out/share/applications
#  cat >$out/bin/mendeleydesktop <<EOF
##!${runtimeShell}
#${fhsEnv}/bin/mendeley-fhs-env ${mendeleySrc}/usr/bin/mendeleydesktop
#EOF
#  chmod +x $out/bin/mendeleydesktop
#
#''

/*
  cp ${desktopItem}/share/applications/* $out/share/applications/

  for size in 16 32 48 256; do
    install -Dm444 ${zoteroSrc}/data/chrome/icons/default/default$size.png \
      $out/share/icons/hicolor/''${size}x''${size}/apps/zotero.png
  done
''
/
/*
  deps = [
    qtbase
    qtsvg
    qtdeclarative
    qtwebchannel
    qtquickcontrols
    qtwebkit
    qtwebengine
    #qtstyleplugins
    #full
    alsaLib
    dbus
    freetype
    fontconfig
    gcc.cc
    gconf
    glib
    icu
    libcap
    libxml2
    libxslt
    nspr
    nss
    orc
    sqlite
    xorg.libX11
    xorg.xcbutilkeysyms
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXcursor
    xorg.libXtst
    xorg.libXrandr
    xorg.xcbutilimage
    zlib
  ];

in

stdenv.mkDerivation {
  name = "mendeley-${version}";

  src = fetchurl {
    url = url;
    sha256 = sha256;
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ dpkg which python ] ++ deps;

  propagatedUserEnvPkgs = [ gconf ];

  unpackPhase = "true";

  installPhase = ''
    dpkg-deb -x $src $out
    mv $out/opt/mendeleydesktop/{bin,lib,share} $out

    interpreter=$(patchelf --print-interpreter $(readlink -f $(which patchelf)))
    patchelf --set-interpreter $interpreter \
             --set-rpath ${stdenv.lib.makeLibraryPath deps}:$out/lib \
             $out/bin/mendeleydesktop
    paxmark m $out/bin/mendeleydesktop

    wrapProgram $out/bin/mendeleydesktop \
      --add-flags "--unix-distro-build" \
      ${stdenv.lib.optionalString autorunLinkHandler # ignore errors installing the link handler
      ''--run "$out/bin/install-mendeley-link-handler.sh $out/bin/mendeleydesktop ||:"''}

    # Remove bundled qt bits
    rm -rf $out/lib/qt
    rm $out/bin/qt* $out/bin/Qt*

    rm -rf $out/opt

    # Patch up link handler script
    wrapProgram $out/bin/install-mendeley-link-handler.sh \
      --prefix PATH ':' ${stdenv.lib.makeBinPath [ which gconf desktop-file-utils ] }
  '';

  dontStrip = true;
  dontPatchElf = true;

  updateScript = import ./update.nix { inherit writeScript; };

  */
