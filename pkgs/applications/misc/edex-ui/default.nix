{ stdenv, fetchFromGitHub, fetchNodeModules, buildNativeModule
, xsel, nodejs-8_x
, glib, gnome3, electron, xdg_utils, makeWrapper, wrapGAppsHook, makeDesktopItem }:

stdenv.mkDerivation rec {
  name = "edex-ui-${version}";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "GitSquared";
    repo = "edex-ui";
    rev = "v${version}";
    sha256 = "1021v60r4d6c15m77z48h2hcpjdlivds6mhf3w8bri5zllcmjgwi";
  };

  node_modules_root = fetchNodeModules {
    inherit src;
    nodejs = nodejs-8_x;
    sha256 = "19m7147rbdncn5gq8p52rwiq5gjmlgdh0nlvzpzblllpk9bdasxf";
  };

  node_modules_src = fetchNodeModules {
    src = "${src}/src";
    nodejs = nodejs-8_x;
    sha256 = "0ik648i06zz9sr00a6mmrrqxjs7yzjvbv9s3sfn7wqcbm2c22xp1";
  };

  node_pty = buildNativeModule {
    name = "node-pty";
    nodejs = nodejs-8_x;
    src = "${node_modules_src}/node-pty";
    sha256 = "100hpblcqgrk7hgvdlfg10rly9d357yfld1abizix0qi3db7zqw7";
    nodeSHA256 = "02wja8cd17ac2rcm9fbvim9v1xbz987j7kjfsh1dm47djjsv8j9z";
    headerSHA256 = "0qmqi9sq0zpqdqz63vjc3aw190fih4dhq7qsfkd3f8f9jww450yz";
  };

  desktopItem = makeDesktopItem rec {
    name = "eDEX-UI";
    exec = "@out@/bin/edex-ui";
    icon = "@out/share/edex-ui/media/logo.svg";
    comment = "eDEX-UI sci-fi interface";
    desktopName = "eDEX-UI";
    categories = "System;";
  };

  buildInputs = [
    glib
    gnome3.gsettings_desktop_schemas
  ];

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook
  ];

  dontWrapGApps = true;

  configurePhase = ''
    cp -r --no-preserve=all $node_modules_root node_modules
    cp -r --no-preserve=all $node_modules_src src/node_modules
  '';

  buildPhase = ''
    rm -rf src/node_modules/node-pty
    cp -r $node_pty src/node_modules/node-pty
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/edex-ui
    mkdir -p $out/share/applications

    cp -r * $out/share/edex-ui

    substitute $desktopItem/share/applications/eDEX-UI.desktop $out/share/applications/eDEX-UI.desktop \
      --subst-var out

    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    ln -s "$out/share/edex-ui/media/logo.svg" "$out/share/icons/hicolor/scalable/apps/edex-ui.svg"
    for i in 16 24 32 48 64 96 128 256 512; do
      ixi="$i"x"$i"
      mkdir -p "$out/share/icons/hicolor/$ixi/apps"
      ln -s "$out/share/edex-ui/media/linuxIcons/$ixi.png" "$out/share/icons/hicolor/$ixi/apps/edex-ui.png"
    done
  '';

  postFixup = ''
    makeWrapper ${electron}/bin/electron $out/bin/edex-ui \
      --add-flags \
        "$out/share/edex-ui/src --without-update" \
        "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${stdenv.lib.makeBinPath [ xsel xdg_utils ]}
  '';

  meta = with stdenv.lib; {
    description = "A fullscreen desktop application resembling a sci-fi computer interface";
    longDescription = ''
      eDEX-UI is a fullscreen desktop application resembling a sci-fi computer interface,
      heavily inspired from DEX-UI and the TRON Legacy movie effects. It runs the shell of
      your choice in a real terminal, and displays live information about your system. It was
      made to be used on large touchscreens but will work nicely on a regular desktop computer
      or perhaps a tablet PC or one of those funky 360° laptops with touchscreens.
    '';
    homepage = "https://github.com/GitSquared/edex-ui";
    license = licenses.gpl3;
    maintainers = with maintainers; [
      eadwu
    ];
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
