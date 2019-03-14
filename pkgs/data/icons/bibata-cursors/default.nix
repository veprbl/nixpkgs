{ fetchFromGitHub, gnome-themes-extra, inkscape, stdenv, xcursorgen }:

stdenv.mkDerivation rec {
  name = "bibata-cursors-${version}";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "KaizIqbal";
    repo = "Bibata_Cursor";
    #rev = "v${version}";
    rev = "f34b0218392afb407f24ae3394cfcbcb2eb8d361";
    sha256 = "0r0n34p3gvfqld0pggrjiys0hnq78cvsfyp46pxkqdnij0smzqak";
  };

  postPatch = ''
    patchShebangs .
    substituteInPlace build.sh --replace "gksu " ""
  '';

  nativeBuildInputs  = [
    gnome-themes-extra
    inkscape
    xcursorgen
  ];

  buildPhase = ''
    HOME="$NIX_BUILD_ROOT" ./build.sh
  '';

  installPhase = ''
    install -dm 0755 $out/share/icons
    cp -pr Bibata_* $out/share/icons/
  '';

  meta = with stdenv.lib; {
    description = "Material Based Cursor";
    homepage = https://github.com/KaizIqbal/Bibata_Cursor;
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rawkode ];
  };
}
