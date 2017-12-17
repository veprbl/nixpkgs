{ stdenv, fetchFromGitHub, gtk_doc, pkgconfig, gobjectIntrospection, intltool
, libgudev, polkit, appstream-glib, gusb, sqlite, libarchive, glib_networking
, libsoup, docbook2x, gpgme, libxslt, libelf, libsmbios, efivar, glibcLocales
, fwupdate, libyaml, valgrind, meson, libuuid, pygobject3, colord
, pillow, ninja, gcab, gnutls, python3Packages, wrapGAppsHook
}:
let
  version = "1.0.3";
in stdenv.mkDerivation {
  name = "fwupd-${version}";
  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "fwupd";
    rev = version;
    sha256 = "0vg9f1gzcvfd7jnfhvv0ylf04fy7cw31ykrim7qik6gbkhr4gr65";
  };

  nativeBuildInputs = [
    meson ninja gtk_doc pkgconfig gobjectIntrospection intltool glibcLocales
    valgrind gcab docbook2x libxslt pygobject3 python3Packages.pycairo wrapGAppsHook
  ];
  buildInputs = [
    polkit appstream-glib gusb sqlite libarchive libsoup libelf libsmbios fwupdate libyaml
    libgudev colord gpgme libuuid pillow gnutls glib_networking efivar
  ];

  LC_ALL = "en_US.UTF-8"; # For po/make-images

  patches = [
    ./fix-missing-deps.patch
  ];
  postPatch = ''
    patchShebangs .
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
