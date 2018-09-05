{ stdenv, fetchurl, intltool, pkgconfig, gnome3, gtk3
, gobjectIntrospection, gdk_pixbuf, librsvg, libgweather, autoreconfHook
, geoclue2, wrapGAppsHook, folks, libchamplain, gfbgraph, file, libsoup
, webkitgtk, gjs, libgee, geocode-glib, evolution-data-server, gnome-online-accounts }:

let
  pname = "gnome-maps";
  version = "3.30.0";
in stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${gnome3.versionBranch version}/${name}.tar.xz";
    sha256 = "1vc3mvhlvz0fl6xmzpfl70cj058sfy5ypfbvdqnqzlch4y6lywwm";
  };

  doCheck = true;

  nativeBuildInputs = [ intltool wrapGAppsHook file autoreconfHook pkgconfig ];
  buildInputs = [
    gobjectIntrospection
    gtk3 geoclue2 gjs libgee folks gfbgraph
    geocode-glib libchamplain libsoup
    gdk_pixbuf librsvg libgweather
    gnome3.gsettings-desktop-schemas evolution-data-server
    gnome-online-accounts gnome3.defaultIconTheme
    webkitgtk
  ];

  # The .service file isn't wrapped with the correct environment
  # so misses GIR files when started. By re-pointing from the gjs
  # entry point to the wrapped binary we get back to a wrapped
  # binary.
  preConfigure = ''
    substituteInPlace "data/org.gnome.Maps.service.in" \
        --replace "Exec=@pkgdatadir@/org.gnome.Maps" \
                  "Exec=$out/bin/gnome-maps"
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Maps;
    description = "A map application for GNOME 3";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
