{ stdenv, fetchurl, pkgconfig, automake, autoconf, libtool, glib, gdk_pixbuf
, gtk3, gobjectIntrospection}:

stdenv.mkDerivation rec {
  ver_maj = "0.7";
  ver_min = "6";
  name = "libnotify-${ver_maj}.${ver_min}";

  src = fetchurl {
    url = "mirror://gnome/sources/libnotify/${ver_maj}/${name}.tar.xz";
    sha256 = "0dyq8zgjnnzcah31axnx6afb21kl7bks1gvrg4hjh3nk02j1rxhf";
  };

  configureFlags = "--enable-introspection";

  buildInputs = [ pkgconfig automake autoconf glib gdk_pixbuf gtk3 gobjectIntrospection ];

  meta = {
    homepage = http://galago-project.org/; # very obsolete but found no better
    description = "A library that sends desktop notifications to a notification daemon";
  };
}
