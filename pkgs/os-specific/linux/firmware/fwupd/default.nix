{ stdenv, fetchFromGitHub, gtk_doc, pkgconfig, gobjectIntrospection, intltool
, libgudev, polkit, appstream-glib, gusb, sqlite, libarchive, glib_networking
, libsoup, docbook2x, gpgme, libxslt, libelf, libsmbios, efivar, glibcLocales
, fwupdate, libyaml, valgrind, meson, libuuid, pygobject3, colord
, pillow, ninja, gcab, gnutls, python3Packages, wrapGAppsHook, json_glib
, shared_mime_info
}:
let
  version = "1.0.4";
in stdenv.mkDerivation {
  name = "fwupd-${version}";
  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "fwupd";
    rev = "1b907a7d253c96d2e5b03ad9bb8c4040a39d9060";
    sha256 = "139v06k57761s3shq14kydsv26pawx8z2avibsdbpimx1sszkgyz";
  };

  nativeBuildInputs = [
    meson ninja gtk_doc pkgconfig gobjectIntrospection intltool glibcLocales
    valgrind gcab docbook2x libxslt pygobject3 python3Packages.pycairo wrapGAppsHook
  ];
  buildInputs = [
    polkit appstream-glib gusb sqlite libarchive libsoup libelf libsmbios fwupdate libyaml
    libgudev colord gpgme libuuid pillow gnutls glib_networking efivar json_glib
  ];

  LC_ALL = "en_US.UTF-8"; # For po/make-images

  patches = [
    ./fix-missing-deps.patch
  ];
  postPatch = ''
    patchShebangs .
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared_mime_info}/share")
  '';

  mesonFlags = [
    "-Dman=false"
    "-Dtests=false"
    "-Dgtkdoc=false"
    "-Dbootdir=/boot"
    "-Dudevdir=lib/udev"
    "-Dsystemdunitdir=lib/systemd/system"
    "--localstatedir=/var"
  ];

  enableParallelBuilding = true;
  meta = {
    homepage = https://fwupd.org/;
    license = [ stdenv.lib.licenses.gpl2 ];
    platforms = stdenv.lib.platforms.linux;
  };
}
