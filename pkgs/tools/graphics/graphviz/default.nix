{ stdenv, fetchurl, pkgconfig, libpng, libjpeg, expat, libXaw
, yacc, libtool, fontconfig, pango, gd, xlibs, gts, gettext, cairo
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "graphviz-2.36.0";

  src = fetchurl {
    url = "http://www.graphviz.org/pub/graphviz/ARCHIVE/${name}.tar.gz";
    sha256 = "0qb30z5sxlbjni732ndad3j4x7l36vsxpxn4fmf5fn7ivvc6dz9p";
  };

  buildInputs =
    [ pkgconfig libpng libjpeg expat libXaw yacc libtool fontconfig
      gd gts
    ] ++ optionals (xlibs != null) [ xlibs.xlibs xlibs.libXrender ]
    ++ optional (stdenv.isDarwin) gettext
    ++ optional (!stdenv.isDarwin) pango;

  CPPFLAGS = optionalString (stdenv.isDarwin) "-I${cairo}/include/cairo";

  configureFlags =
    [ "--with-pngincludedir=${libpng}/include"
      "--with-pnglibdir=${libpng}/lib"
      "--with-jpegincludedir=${libjpeg}/include"
      "--with-jpeglibdir=${libjpeg}/lib"
      "--with-expatincludedir=${expat}/include"
      "--with-expatlibdir=${expat}/lib"
    ]
    ++ optional (xlibs == null) "--without-x";

  preBuild = ''
    sed -e 's@am__append_5 *=.*@am_append_5 =@' -i lib/gvc/Makefile
  '';

  # "command -v" is POSIX, "which" is not
  postInstall = ''
    sed -i 's|`which lefty`|"'$out'/bin/lefty"|' $out/bin/dotty
    ${optionalString (!stdenv.isDarwin) ''sed -i 's|which|command -v|' $out/bin/vimdot''}
  '';

  meta = {
    homepage = "http://www.graphviz.org/";
    description = "Open source graph visualization software";

    longDescription = ''
      Graphviz is open source graph visualization software. Graph
      visualization is a way of representing structural information as
      diagrams of abstract graphs and networks. It has important
      applications in networking, bioinformatics, software engineering,
      database and web design, machine learning, and in visual
      interfaces for other technical domains.
    '';

    hydraPlatforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ simons bjornfor offline ];
  };
}
