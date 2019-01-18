{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, libxml2, xdg-desktop-portal, gtk3, glib, wrapGAppsHook, gnome3 }:

stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal-gtk";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = pname;
    rev = version;
    sha256 = "0ka08z5803v7lmacfc5cnpq7b1nq4kgwrdskbni4qh7c8gkmyh0h";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig libxml2 xdg-desktop-portal wrapGAppsHook ];
  buildInputs = [ glib gtk3 gnome3.gsettings-desktop-schemas ];

  meta = with stdenv.lib; {
    description = "Desktop integration portals for sandboxed apps";
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
    license = licenses.lgpl21;
  };
}
