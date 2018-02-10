{ stdenv, fetchFromGitHub, pkgconfig, gettext, gtk3, glib
, gtk_doc, libarchive, gobjectIntrospection
, sqlite, libsoup, gcab, attr, acl, docbook_xsl, libxslt
, libuuid, json_glib, meson, gperf, ninja
}:
stdenv.mkDerivation rec {
  name = "appstream-glib-0.7.6";

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "appstream-glib";
    rev = stdenv.lib.replaceStrings ["." "-"] ["_" "_"] name;
    sha256 = "1nzm6w9n7fb2m06w88gwszaqf74bnip87ay0ca59wajq6y4mpfgv";
  };

  nativeBuildInputs = [ meson pkgconfig ninja ];
  buildInputs = [ glib gtk_doc gettext sqlite libsoup
                  gcab attr acl docbook_xsl libuuid json_glib
                  libarchive gobjectIntrospection gperf libxslt ];
  propagatedBuildInputs = [ gtk3 ];
  mesonFlags = [ "-Drpm=false" "-Dstemmer=false" "-Ddep11=false" ];

  meta = with stdenv.lib; {
    description = "Objects and helper methods to read and write AppStream metadata";
    homepage    = https://github.com/hughsie/appstream-glib;
    license     = licenses.lgpl21Plus;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ lethalman matthewbauer ];
  };
}
