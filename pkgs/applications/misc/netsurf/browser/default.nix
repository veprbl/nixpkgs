{ stdenv, fetchurl, pkgconfig, libpng, openssl, curl, gtk2, check, SDL
, libxml2, libidn, perl, nettools, perlPackages
, libXcursor, libXrandr, makeWrapper
, uilib ? "framebuffer"
, buildsystem
, nsgenbind
, libnsfb
, libwapcaplet
, libparserutils
, libcss
, libhubbub
, libdom
, libnsbmp
, libnsgif
, libnsutils
, libutf8proc
}:

stdenv.mkDerivation rec {

  name = "netsurf-${version}";
  version = "3.8";

  # UI libs incldue Framebuffer, and gtk

  src = fetchurl {
    url = "http://download.netsurf-browser.org/netsurf/releases/source/netsurf-${version}-src.tar.gz";
    sha256 = "0hjm1h4m1i913y4mhkl7yqdifn8k70fwi58zdh6faypawzryc3m0";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libpng openssl curl gtk2 check libxml2 libidn perl
    nettools perlPackages.HTMLParser libXcursor libXrandr makeWrapper SDL
    buildsystem
    nsgenbind
    libnsfb
    libwapcaplet
    libparserutils
    libcss
    libhubbub
    libdom
    libnsbmp
    libnsgif
    libnsutils
    libutf8proc
 ];

  preConfigure = ''
    cat <<EOF > Makefile.conf
    override NETSURF_GTK_RESOURCES := $out/share/Netsurf/${uilib}/res
    override NETSURF_USE_GRESOURCE := YES
    EOF
  '';

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${buildsystem}/share/netsurf-buildsystem"
    "TARGET=${uilib}"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = http://www.netsurf-browser.org/;
    description = "Free opensource web browser";
    license = licenses.gpl2;
    maintainers = [ maintainers.vrthra ];
    platforms = platforms.linux;
  };
}
