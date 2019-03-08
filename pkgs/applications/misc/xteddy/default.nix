{ stdenv, fetchurl, pkg-config, xorg, imlib2 }:

stdenv.mkDerivation rec {
  name = "xteddy-${version}";
  version = "2.2";
  src = fetchurl {
    url = "http://deb.debian.org/debian/pool/main/x/xteddy/xteddy_${version}.orig.tar.gz";
    sha256 = "1qli69im6pani8wzmryavndspbcwc4298yl5d6s7qy085qg5m26q";
  };
  postPatch = ''
    sed -i -e 's,/usr/\(local\)\?share,${placeholder "out"}/share,' \
      configure xteddy.c Makefile.in images/Makefile.in
  '';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ imlib2 xorg.libX11 xorg.libXext ];
  makeFlags = [ "LIBS=-lXext" ];
  postInstall = ''
    # remove broken scripts
    rm $out/bin/{xtoys,xteddy_test}
  '';

  meta = with stdenv.lib; {
    description = "cuddly teddy bear for your X desktop";
    homepage = http://weber.itn.liu.se/~stegu/xteddy/;
    license = licenses.gpl2;
    maintainers = [ maintainers.xaverdh ];
    platforms = platforms.linux;
  };
}
