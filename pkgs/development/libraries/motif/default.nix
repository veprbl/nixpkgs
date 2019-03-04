{ stdenv, fetchurl, pkgconfig, libtool
, xlibsWrapper, xbitmaps, libXrender, libXmu, libXt
, expat, libjpeg, libpng, libiconv
, flex
, libXp, libXau
, demoSupport ? false
}:
# refer to the gentoo package

stdenv.mkDerivation rec {
  name = "motif-${version}";
  version = "2.3.8";

  src = fetchurl {
    url = "mirror://sourceforge/motif/${name}.tar.gz";
    sha256 = "1rxwkrhmj8sfg7dwmkhq885valwqbh26d79033q7vb7fcqv756w5";
  };

  buildInputs = [
    libtool
    xlibsWrapper xbitmaps libXrender libXmu libXt
    expat libjpeg libpng libiconv
  ];

  nativeBuildInputs = [ pkgconfig flex ];

  propagatedBuildInputs = [ libXp libXau ];

  hardeningDisable = [ "format" ];

  makeFlags = [ "CFLAGS=-fno-strict-aliasing" ];

  prePatch = stdenv.lib.optionalString (!demoSupport) ''
    sed '/^SUBDIRS =,^$/s/\<demos\>//' -i Makefile.{am,in}
  '';

  patches = [ ./Remove-unsupported-weak-refs-on-darwin.patch
              ./Add-X.Org-to-bindings-file.patch
            ];

  meta = with stdenv.lib; {
    homepage = http://motif.ics.com;
    description = "Unix standard widget-toolkit and window-manager";
    platforms = with platforms; linux ++ darwin;
    license = with licenses; [ lgpl21 ];
    maintainers = with maintainers; [ ];
  };
}
