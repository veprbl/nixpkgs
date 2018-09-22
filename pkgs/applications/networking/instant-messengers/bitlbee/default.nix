{ fetchurl, stdenv, gnutls, glib, pkgconfig, check, libotr, python
, enableLibPurple ? false, pidgin ? null
, enablePam ? false, pam ? null
, fetchFromGitHub
}:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "bitlbee-3.5.1";

  src = fetchFromGitHub {
    owner = "bitlbee";
    repo = "bitlbee";
    rev = "0b1448f070917daf4966097a06b47fc4b2ce0c92";
    sha256 = "0ri9rzn3s76ggpq0s17zpq1mcxgimk9c4300d70a4njcjrslwfnm";
  };

  nativeBuildInputs = [ pkgconfig ] ++ optional doCheck check;

  buildInputs = [ gnutls glib libotr python ]
    ++ optional enableLibPurple pidgin
    ++ optional enablePam pam;

  configureFlags = [
    "--otr=1"
    "--ssl=gnutls"
    "--pidfile=/var/lib/bitlbee/bitlbee.pid"
  ] ++ optional enableLibPurple "--purple=1"
    ++ optional enablePam "--pam=1";

  installTargets = [ "install" "install-dev" ];

  doCheck = !enableLibPurple; # Checks fail with libpurple for some reason
  checkPhase = ''
    # check flags set VERBOSE=y which breaks the build due overriding a command
    make check
  '';

  enableParallelBuilding = true;

  meta = {
    description = "IRC instant messaging gateway";

    longDescription = ''
      BitlBee brings IM (instant messaging) to IRC clients.  It's a
      great solution for people who have an IRC client running all the
      time and don't want to run an additional MSN/AIM/whatever
      client.

      BitlBee currently supports the following IM networks/protocols:
      XMPP/Jabber (including Google Talk), MSN Messenger, Yahoo!
      Messenger, AIM and ICQ.
    '';

    homepage = https://www.bitlbee.org/;
    license = licenses.gpl2Plus;

    maintainers = with maintainers; [ wkennington pSub ];
    platforms = platforms.gnu ++ platforms.linux;  # arbitrary choice
  };
}
