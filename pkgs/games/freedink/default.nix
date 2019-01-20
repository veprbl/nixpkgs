{ stdenv, fetchurl, SDL2, SDL2_mixer, SDL2_image, SDL2_ttf, SDL2_gfx, glm
, pkgconfig, intltool, fontconfig, libzip, zip, zlib, cxxtest }:

let
  freedink_data = stdenv.mkDerivation rec {
    name = "freedink-data-${version}";
    version = "1.08.20190120";

    src = fetchurl {
      url = "mirror://gnu/freedink/${name}.tar.gz";
      sha256 = "17gvryadlxk172mblbsil7hina1z5wahwaxnr6g3mdq57dvl8pvi";
    };

    prePatch = "substituteInPlace Makefile --replace /usr/local $out";
  };

in stdenv.mkDerivation rec {
  name = "freedink-${version}";
  version = "109.2";

  src = fetchurl {
    url = "mirror://gnu/freedink/${name}.tar.gz";
    sha256 = "0rk53ld20qafrrappljws0wbjf46cc31frxhqxd2ws9idcp0282l";
  };

  nativeBuildInputs = [
    pkgconfig intltool 
  ];
  buildInputs = [
    SDL2 SDL2_mixer SDL2_image SDL2_ttf SDL2_gfx
    fontconfig libzip zip zlib glm
    cxxtest
  ];

  postInstall = ''
    mkdir -p "$out/share/"
    ln -s ${freedink_data}/share/dink "$out/share/"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "A free, portable and enhanced version of the Dink Smallwood game engine";

    longDescription = ''
      GNU FreeDink is a new and portable version of the Dink Smallwood
      game engine, which runs the original game as well as its D-Mods,
      with close compatibility, under multiple platforms.
    '';

    homepage = http://www.freedink.org/;
    license = stdenv.lib.licenses.gpl3Plus;

    maintainers = [ stdenv.lib.maintainers.bjg ];
    platforms = stdenv.lib.platforms.all;
    hydraPlatforms = stdenv.lib.platforms.linux; # sdl-config times out on darwin
  };
}
