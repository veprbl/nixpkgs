{ stdenv, fetchzip, pkg-config, xorg, imlib2, makeWrapper }:

stdenv.mkDerivation rec {
  name = "xteddy-${version}";
  version = "2.2";
  src = fetchzip {
    url = "http://deb.debian.org/debian/pool/main/x/xteddy/xteddy_${version}.orig.tar.gz";
    sha256 = "0sap4fqvs0888ymf5ga10p3n7n5kr35j38kfsfd7nj0xm4hmcma3";
  };
  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ imlib2 xorg.libX11 xorg.libXext ];
  makeFlags = [ "LIBS=-lXext" ];
  postInstall = ''
    cp -R images $out/share/images
    # remove broken scripts
    rm $out/bin/{xtoys,xteddy_test}
  '';
  postFixup = ''
    wrapProgram $out/bin/xteddy --run "cd $out/share/images/"
  '';
  meta = with stdenv.lib; {
    description = "cuddly teddy bear for your X desktop";
    homepage = http://weber.itn.liu.se/~stegu/xteddy/;
    license = licenses.gpl2;
    maintainers = [ maintainers.xaverdh ];
    platforms = platforms.linux;
  };
}
