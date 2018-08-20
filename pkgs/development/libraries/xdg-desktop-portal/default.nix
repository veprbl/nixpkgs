{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, libxml2, glib, pipewire, fuse }:

let
  version = "1.0";
in stdenv.mkDerivation rec {
  name = "xdg-desktop-portal-${version}";

  outputs = [ "out" "installedTests" ];

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "xdg-desktop-portal";
    rev = version;
    sha256 = "0icj4vnmdrsxc2b06mwrja26xxbi0ms8h7gcp2ijxbcncxf5ln66";
  };

  patches = [
    ./respect-path-env-var.patch
  ];

  nativeBuildInputs = [ autoreconfHook pkgconfig libxml2 ];
  buildInputs = [ glib pipewire fuse ];

  doCheck = true;

  configureFlags = [
    "--enable-installed-tests"
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
