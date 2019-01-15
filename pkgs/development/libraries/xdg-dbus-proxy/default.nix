{ stdenv, fetchurl, pkgconfig, glib }:

let
  version = "0.1.1";
in stdenv.mkDerivation rec {
  name = "xdg-dbus-proxy-${version}";

  src = fetchurl {
    url = "https://github.com/flatpak/xdg-dbus-proxy/releases/download/${version}/${name}.tar.xz";
    sha256 = "1w8yg5j51zsr9d97d4jjp9dvd7iq893p2xk54i6lf3lx01ribdqh";
  };

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [ glib ];

  doCheck = false; # needs dbus-daemon instance

  meta = with stdenv.lib; {
    description = "DBus proxy for Flatpak and others";
    homepage = https://flatpak.org/;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
