{ stdenv, fetchFromGitHub, pkgconfig, gdk_pixbuf, optipng, librsvg, gtk3, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  name = "elementary-xfce-icon-theme-${version}";
  version = "0.13.1.0.1"; # not really, git

  src = fetchFromGitHub {
    owner = "shimmerproject";
    repo = "elementary-xfce";
    #rev = "v${version}";
    rev = "5a5d511bd5b19cc708f8b43cc2a2ff41bfc06c8f";
    sha256 = "0cp1ijayd65p14nbid5ppz75cnxic66i59za4z2w79559j3z872j";
  };

  nativeBuildInputs = [ pkgconfig gdk_pixbuf librsvg optipng gtk3 hicolor-icon-theme ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace svgtopng/Makefile --replace "-O0" "-O"

    for x in */index.theme; do
      echo "Fixing theme name for $x"
      echo "before: $(grep 'Name=' $x)"
      sed -i $x -e "s|Name=.*|Name=$(dirname $x)|"
      echo "after: $(grep 'Name=' $x)"
    done
  '';

  postInstall = ''
    make icon-caches
  '';

  meta = with stdenv.lib; {
    description = "Elementary icons for Xfce and other GTK+ desktops like GNOME";
    homepage = https://github.com/shimmerproject/elementary-xfce;
    license = licenses.gpl2;
    # darwin cannot deal with file names differing only in case
    platforms = platforms.linux;
    maintainers = with maintainers; [ davidak ];
  };
}
