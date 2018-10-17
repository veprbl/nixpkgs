{ fetchFromGitLab, stdenv, fetchpatch, meson, ninja, intltool, pkgconfig, gtk-doc, docbook_xsl, docbook_xml_dtd_412, glib, json-glib, libsoup, libnotify, gdk_pixbuf, vala
, modemmanager, avahi, glib-networking, wrapGAppsHook, gobjectIntrospection
, python3
, withDemoAgent ? false
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "geoclue-${version}";
  version = "2.5.1";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "geoclue";
    repo = "geoclue";
    rev = version;
    sha256 = "0vww6irijw5ss7vawkdi5z5wdpcgw4iqljn5vs3vbd4y3d0lzrbs";
  };

  outputs = [ "out" "dev" "devdoc" ];

  nativeBuildInputs = [
    meson ninja pkgconfig intltool wrapGAppsHook gobjectIntrospection
    # devdoc
    gtk-doc docbook_xsl docbook_xml_dtd_412
  ];

  buildInputs = [
    glib json-glib libsoup avahi vala
  ] ++ optionals withDemoAgent [
    libnotify gdk_pixbuf
  ] ++ optionals (!stdenv.isDarwin) [ modemmanager ];

  propagatedBuildInputs = [ glib glib-networking python3 ];

  mesonFlags = [
    "-Dsystemd-system-unit-dir=${placeholder "out"}/etc/systemd/system"
    "-Dintrospection=true"
    "-Dgtk-doc=true"
    "-Ddemo-agent=${if withDemoAgent then "true" else "false"}"
    "-Dsysconfdir=${placeholder "out"}/etc"
  ] ++ optionals stdenv.isDarwin [
    "-D3g-source=false"
    "-Dcdma-source=false"
    "-Dmodem-gps=source=false"
    "-Dnmea-source=false"
  ];

  postPatch = ''
    substituteInPlace demo/install-file.py \
      --replace '#!/usr/bin/env python3' '#!${python3.interpreter}'
  '';

  postInstall = ''
    substituteInPlace $out/etc/systemd/system/geoclue.service \
      --replace "ExecStart=libexec/geoclue" \
                "ExecStart=$out/libexec/geoclue"
  '';

  meta = with stdenv.lib; {
    description = "Geolocation framework and some data providers";
    homepage = https://gitlab.freedesktop.org/geoclue/geoclue/wikis/home;
    maintainers = with maintainers; [ raskin garbas ];
    platforms = with platforms; linux ++ darwin;
    license = licenses.lgpl2;
  };
}
