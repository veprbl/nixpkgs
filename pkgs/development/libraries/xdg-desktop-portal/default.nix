{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, libxml2, glib, pipewire, fontconfig, flatpak, fuse }:

let
  version = "1.1.0";
in stdenv.mkDerivation rec {
  name = "xdg-desktop-portal-${version}";

  outputs = [ "out" "installedTests" ];

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "xdg-desktop-portal";
    rev = version;
    sha256 = "10dv628gci6vcs0rbyp4wb6yvigw2i1jj9x7ii6ckxjir5rff5dx";
  };

  patches = [
    ./respect-path-env-var.patch
  ];

  nativeBuildInputs = [ autoreconfHook pkgconfig libxml2 ];
  buildInputs = [ glib pipewire fontconfig flatpak fuse ];

  doCheck = true;

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
