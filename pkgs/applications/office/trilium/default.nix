{ stdenv, fetchurl, autoPatchelfHook, atomEnv, makeWrapper, makeDesktopItem }:

let
  description = "Trilium Notes is a hierarchical note taking application with focus on building large personal knowledge bases.";
  desktopItem = makeDesktopItem {
    name = "Trilium";
    exec = "trilium";
    icon = "trilium";
    comment = description;
    desktopName = "Trilium Notes";
    categories = "Office";
  };
  version = "0.29.0-beta";

  # Fetch from source repo, no longer included in release.
  # (they did special-case icon.png but we want the scalable svg)
  # Use the version here to ensure we get any changes.
  trilium_svg = fetchurl {
    url = "https://raw.githubusercontent.com/zadam/trilium/v${version}/src/public/images/trilium.svg";
    sha256 = "1rgj7pza20yndfp8n12k93jyprym02hqah36fkk2b3if3kcmwnfg";
  };

in stdenv.mkDerivation rec {
  name = "trilium-${version}";
  inherit version;

  src = fetchurl {
    url = "https://github.com/zadam/trilium/releases/download/v${version}/trilium-linux-x64-${version}.tar.xz";
    sha256 = "0p6xhp3a43vn9ibj4n54bljjw8d3wcq4c77q7v7wnfjarv3x1s58";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = atomEnv.packages;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/trilium
    mkdir -p $out/share/{applications,icons/hicolor/scalable/apps}

    cp -r ./* $out/share/trilium
    ln -s $out/share/trilium/trilium $out/bin/trilium

    ln -s ${trilium_svg} $out/share/icons/hicolor/scalable/apps/trilium.svg
    cp ${desktopItem}/share/applications/* $out/share/applications
  '';


  # This "shouldn't" be needed, remove when possible :)
  preFixup = ''
    wrapProgram $out/bin/trilium --prefix LD_LIBRARY_PATH : "${atomEnv.libPath}:$out/share/trilium"
  '';

  dontStrip = true;

  meta = with stdenv.lib; {
    inherit description;
    homepage = https://github.com/zadam/trilium;
    license = licenses.agpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ emmanuelrosa dtzWill ];
  };
}
