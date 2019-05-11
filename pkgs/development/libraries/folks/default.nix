{ fetchurl, stdenv, pkgconfig, glib, gnome3, nspr, intltool, gobject-introspection
, vala, sqlite, libxml2, dbus-glib, libsoup, nss, dbus, libgee
, telepathy-glib, evolution-data-server, libsecret, db }:

# TODO: enable more folks backends

stdenv.mkDerivation rec {
  pname = "folks";
  version = "0.12.1";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "0xfl6rnzhdbmw1q26xiq34cdiy7a9karpi2r7wyplnnz1zaz5a9w";
  };

  propagatedBuildInputs = [ glib libgee sqlite ];

  buildInputs = [
    dbus-glib telepathy-glib evolution-data-server
    libsecret libxml2 libsoup nspr nss db
  ];

  checkInputs = [ dbus ];

  nativeBuildInputs = [ pkgconfig intltool vala gobject-introspection ];

  configureFlags = [ "--disable-fatal-warnings" ];

  enableParallelBuilding = true;

  postBuild = "rm -rf $out/share/gtk-doc";

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "A library that aggregates people from multiple sources to create metacontacts";
    homepage = https://wiki.gnome.org/Projects/Folks;
    license = stdenv.lib.licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = stdenv.lib.platforms.gnu ++ stdenv.lib.platforms.linux;  # arbitrary choice
  };
}
