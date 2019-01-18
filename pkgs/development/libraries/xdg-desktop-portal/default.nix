{ stdenv, fetchFromGitHub, fetchpatch, autoreconfHook, pkgconfig, libxml2, glib, pipewire, fontconfig, flatpak, acl, dbus, fuse, wrapGAppsHook, gdk_pixbuf, gnome3 }:

stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal";
  version = "1.1.1";

  outputs = [ "out" "installedTests" ];

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = pname;
    rev = version;
    sha256 = "1p1fanmabprhygkb6lxvnn9kc3mizz9mhmz8727dx4zr3ra90jfp";
  };

  patches = [
    ./respect-path-env-var.patch
  ];

  nativeBuildInputs = [ autoreconfHook pkgconfig libxml2 wrapGAppsHook ];
  buildInputs = [ glib pipewire fontconfig flatpak acl dbus fuse gdk_pixbuf gnome3.gsettings-desktop-schemas ];

  doCheck = true; # XXX: investigate!

  configureFlags = [
    "--enable-installed-tests"
    "--disable-geoclue" # Requires 2.5.2, not released yet
  ];

  makeFlags = [
    "installed_testdir=$(installedTests)/libexec/installed-tests/xdg-desktop-portal"
    "installed_test_metadir=$(installedTests)/share/installed-tests/xdg-desktop-portal"
  ];

  meta = with stdenv.lib; {
    description = "Desktop integration portals for sandboxed apps";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ jtojnar ];
    platforms = platforms.linux;
  };
}
