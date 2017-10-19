{ stdenv, fetchurl, cmake, pkgconfig, SDL2, SDL2_image , curl
, libogg, libvorbis, mesa, openal, boost, glew
}:

stdenv.mkDerivation rec {
  name = "supertux-${version}";
  version = "0.5.1";

  src = fetchurl {
    url = "https://github.com/SuperTux/supertux/releases/download/v${version}/SuperTux-v${version}-Source.tar.gz";
    sha256 = "1i8avad7w7ikj870z519j383ldy29r6f956bs38cbr8wk513pp69";
  };

  nativeBuildInputs = [ pkgconfig cmake ];

  buildInputs = [ SDL2 SDL2_image curl libogg libvorbis mesa openal boost glew ];

  # Ensure math.h is included before 'type' macro ('#define type...')
  # Based on: https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=222402
  prePatch = ''
    sed -i -e '1i#include <math.h>' external/squirrel/squirrel/sqvm.cpp
  '';

  cmakeFlags = [ "-DENABLE_BOOST_STATIC_LIBS=OFF" ];

  postInstall = ''
    mkdir $out/bin
    ln -s $out/games/supertux2 $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Classic 2D jump'n run sidescroller game";
    homepage = http://supertux.github.io/;
    license = licenses.gpl2;
    maintainers = with maintainers; [ pSub ];
    platforms = with platforms; linux;
  };
}
