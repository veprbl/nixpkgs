{ stdenv, fetchurl
, edex-ui-bare, makeDesktopItem
, glib, gnome3, electron, xdg_utils, makeWrapper, wrapGAppsHook }:

let
  desktopItem = makeDesktopItem rec {
    name = "eDEX-UI";
    exec = "@out@/bin/edex-ui";
    icon = "${edex-ui-bare}/media/logo.svg";
    comment = "eDEX-UI sci-fi interface";
    desktopName = "eDEX-UI";
    categories = "System;";
  };
in stdenv.mkDerivation {
  name = "edex-ui-${edex-ui-bare.version}";
  inherit (edex-ui-bare) version;

  unpackPhase = ":";

  buildInputs = [
    glib
    gnome3.gsettings_desktop_schemas
  ];

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook
  ];

  dontWrapGApps = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications

    substitute ${desktopItem}/share/applications/eDEX-UI.desktop $out/share/applications/eDEX-UI.desktop \
      --subst-var out

    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    ln -s "${edex-ui-bare}/media/logo.svg" "$out/share/icons/hicolor/scalable/apps/edex-ui.svg"
    for i in 16 24 32 48 64 96 128 256 512; do
      ixi="$i"x"$i"
      mkdir -p "$out/share/icons/hicolor/$ixi/apps"
      ln -s "${edex-ui-bare}/media/linuxIcons/$ixi.png" "$out/share/icons/hicolor/$ixi/apps/edex-ui.png"
    done
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/edex-ui \
      --add-flags \
        "${edex-ui-bare}/src --without-update" \
        "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${xdg_utils}/bin
  '';

  inherit (edex-ui-bare.meta // {
    platforms = [
      "i386-linux"
      "x86_64-linux"
    ];
  });
}
