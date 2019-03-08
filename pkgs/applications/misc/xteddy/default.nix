{ stdenv, fetchurl, pkg-config, xorg, imlib2 }:

stdenv.mkDerivation rec {
  name = "xteddy-${version}";
  version = "2.2";
  src = fetchurl {
    url = "http://deb.debian.org/debian/pool/main/x/xteddy/xteddy_${version}.orig.tar.gz";
    sha256 = "1qli69im6pani8wzmryavndspbcwc4298yl5d6s7qy085qg5m26q";
  };
  postPatch = ''
    for x in configure xteddy.c Makefile.in images/Makefile.in xteddy_test xtoys; do
      substituteInPlace $x --replace /usr/share $out/share --replace /usr/local/share $out/share
    done
    substituteInPlace xtoys --replace /usr/games/xteddy $out/bin/xteddy
  '';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ imlib2 xorg.libX11 xorg.libXext ];
  makeFlags = [ "LIBS=-lXext" ];
  postInstall = ''
    # Remove script that launches xteddy on every image, probably not desired :)
    rm $out/bin/xteddy_test

    # Create aliases for various toys O:)
    for x in $out/share/xteddy/*.png; do
      ln -rsvf $out/bin/{xteddy,$(basename $x .png)} || :
    done
  '';

  meta = with stdenv.lib; {
    description = "cuddly teddy bear for your X desktop";
    homepage = http://weber.itn.liu.se/~stegu/xteddy/;
    license = licenses.gpl2;
    maintainers = [ maintainers.xaverdh ];
    platforms = platforms.linux;
  };
}
