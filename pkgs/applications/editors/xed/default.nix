{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, glib, gtk3, gtksourceview3, libpeas, libxml2
, gobject-introspection, gspell
}:

stdenv.mkDerivation rec {
  pname = "xed";
  #version = "master.mint19"; # not sure if stable
  version = "2.0.2-mint19";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = pname;
    #rev = "refs/tags/${version}";
    rev = "master.mint19";
    sha256 = "0c0scd6fc1l1q90lcvs7hjw8m9xpa30yz8wg9a4kwd0yl9wqhjj9";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [ glib gtk3 gtksourceview3 libpeas libxml2 gobject-introspection gspell ];
}
