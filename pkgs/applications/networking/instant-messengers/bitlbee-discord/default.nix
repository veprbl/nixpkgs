{ stdenv, fetchFromGitHub, bitlbee, autoconf, automake, libtool, pkgconfig, glib }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "bitlbee-discord-${version}";
  version = "2017-05-29";

  src = fetchFromGitHub {
    owner = "sm00th";
    repo = "bitlbee-discord";
    rev = "6a2f160b92238504a034078e410b37e1b6745d63";
    sha256 = "1mpp1gkf41pj19dv28jc5gjf0q25p1iwzk35cc8cm54532zsrbbg";
  };

  buildInputs = [ bitlbee autoconf automake libtool pkgconfig glib ];

  preConfigure = ''
    export BITLBEE_PLUGINDIR=$out/lib/bitlbee
    ./autogen.sh
  '';

  meta = {
    description = "Discord protocol plugin for BitlBee";

    homepage = https://github.com/sm00th/bitlbee-discord;
    license = licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
  };
}
