{ stdenv, fetchurl, fetchgit, meson, ninja, pkgconfig, vala, glib, libxslt, gtk3, wrapGAppsHook
, webkitgtk, json-glib, librest, libsecret, gtk-doc, gobject-introspection, dbus
, gettext, icu, glib-networking, hicolor-icon-theme
, libsoup, docbook_xsl, docbook_xml_dtd_412, gnome3, gcr, kerberos
}:

let
  pname = "gnome-online-accounts";
  version = "3.32.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchgit {
    url = https://gitlab.gnome.org/GNOME/gnome-online-accounts;
    rev = "refs/tags/${version}";
    sha256 = "18yi66j4h81f5z4lzbb9zsqisn3m2n34iz2l75i638qsbpcyvb1a";
  };
  #src = fetchurl {
  #  url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
  #  sha256 = "1anlx0rb2hafg9929pgfms25mdz23sd0vdva06h6zlf8f5byc68w";
  #};

  outputs = [ "out" "man" "dev" "devdoc" ];

  mesonFlags = [
    "-Dgoabackend=true"

    "-Dexchange=true"
    "-Dkerberos=true"
    "-Dlastfm=true"
    "-Dmedia_server=true"
    "-Downcloud=true"
    "-Dpocket=true"
    "-Dgoogle=true"
    "-Dflickr=true"
    "-Dfacebook=true"
    "-Dwindows_live=true"
    #"-Dtodoist=true"
    "-Dgtk_doc=true"
    "-Dman=true"
  ];
  #configureFlags = [
  #  "--enable-media-server"
  #  "--enable-kerberos"
  #  "--enable-lastfm"
  #  "--enable-todoist"
  #  "--enable-gtk-doc"
  #  "--enable-documentation"
  #];

  enableParallelBuilding = true;

  nativeBuildInputs = [
    meson ninja
    pkgconfig gobject-introspection vala gettext wrapGAppsHook
    libxslt docbook_xsl docbook_xml_dtd_412 gtk-doc
    hicolor-icon-theme # for setup-hook
  ];
  buildInputs = [
    glib gtk3 webkitgtk json-glib librest libsecret glib-networking icu libsoup
    gcr kerberos dbus
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
