{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, libxml2, xdg-desktop-portal, gtk3, glib }:

let
  version = "1.0";
in stdenv.mkDerivation rec {
  name = "xdg-desktop-portal-gtk-${version}";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "xdg-desktop-portal-gtk";
    rev = version;
    sha256 = "19kpg5l0p6ljdr6q549qzy9lbsw3h03qaddqn8mh49zca6hnyhyq";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig libxml2 xdg-desktop-portal ];
  buildInputs = [ glib gtk3 ];

  meta = with stdenv.lib; {
    description = "Desktop integration portals for sandboxed apps";
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
    license = licenses.lgpl21;
  };
}
