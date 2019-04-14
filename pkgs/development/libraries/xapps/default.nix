{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, glib, gtk3, gtksourceview3, libpeas, libxml2
, gobject-introspection, gspell
, libgnomekbd
}:

stdenv.mkDerivation rec {
  pname = "xapps";
  #version = "master.mint19"; # not sure if stable
  version = "2.0.2-mint19";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = pname;
    #rev = "refs/tags/${version}";
    rev = "refs/tags/master.mint19";
    sha256 = "0rgm7m5sxrngxkq0pc06mq08k43fxin17jli203bpxd0z5p0flnk";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];

  buildInputs = [ glib gtk3 gtksourceview3 libpeas libxml2 gobject-introspection gspell libgnomekbd ];
}

