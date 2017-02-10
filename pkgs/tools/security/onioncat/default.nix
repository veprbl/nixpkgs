{ stdenv, fetchurl, pkgconfig, libevent, openssl, zlib, torsocks
, libseccomp, systemd, libcap
}:

stdenv.mkDerivation rec {
  name = "onioncat-0.2.9.9";

  src = fetchurl {
    url = "https://www.cypherpunk.at/ocat/download/Source/current/onioncat-0.2.2.r569.tar.gz";
    sha256 = "1fzh4d922m4761lha7chh9zd2biaaqjjpc1x4p91ywrw1pg7fxrp";
  };

  meta = with stdenv.lib; {
    homepage = https://www.onioncat.org/;
    description = "An Anonymous VPN-Adapter";

    license = licenses.bsd3;

    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
