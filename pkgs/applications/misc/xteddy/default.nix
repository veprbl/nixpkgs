{ stdenv, fetchurl, pkg-config, xorg, imlib2 }:

stdenv.mkDerivation rec {
  name = "xteddy-${version}";
  version = "2.2";
  src = fetchurl {
    url = "http://deb.debian.org/debian/pool/main/x/xteddy/xteddy_${version}.orig.tar.gz";
    sha256 = "1qli69im6pani8wzmryavndspbcwc4298yl5d6s7qy085qg5m26q";
  };
  postPatch = ''
    sed -i -e 's,/usr/\(local\)\?share,${placeholder "out"}/share,g' \
      configure xteddy.c Makefile.in images/Makefile.in xteddy_test xtoys
    substituteInPlace xtoys --replace /usr/games/xteddy $out/bin/xteddy
  '';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ imlib2 xorg.libX11 xorg.libXext ];
  makeFlags = [ "LIBS=-lXext" ];

  meta = with stdenv.lib; {
    description = "cuddly teddy bear for your X desktop";
    homepage = http://weber.itn.liu.se/~stegu/xteddy/;
    license = licenses.gpl2;
    maintainers = [ maintainers.xaverdh ];
    platforms = platforms.linux;
  };
}
