{ stdenv, fetchurl, pkgconfig, vala, glib, libxslt, gtk, wrapGAppsHook
, webkitgtk, json-glib, rest, libsecret, dbus-glib, gtk-doc
, telepathy-glib, gettext, icu, glib-networking
, libsoup, docbook_xsl, docbook_xsl_ns, gnome3, gcr, kerberos
}:

let
  pname = "gnome-online-accounts";
  version = "3.30.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "1hyg9g7l4ypnirx2j7ms2vr8711x90aybpq3s3wa20ma8a4xin97";
  };

  outputs = [ "out" "man" "dev" "devdoc" ];

  configureFlags = [
    "--enable-media-server"
    "--enable-kerberos"
    "--enable-lastfm"
    "--enable-todoist"
    "--enable-gtk-doc"
  ];

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkgconfig vala gettext wrapGAppsHook
    libxslt docbook_xsl docbook_xsl_ns gtk-doc
  ];
  buildInputs = [
    glib gtk webkitgtk json-glib rest libsecret dbus-glib telepathy-glib glib-networking icu libsoup
    gcr kerberos
  ];

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
  };
}
