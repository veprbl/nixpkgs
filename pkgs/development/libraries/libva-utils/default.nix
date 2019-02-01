{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig
, libdrm, libva
}:

stdenv.mkDerivation rec {
  name = "libva-utils-${version}";
  #inherit (libva) version;
  version = "2.3.0"; # no 2.4.0 "yet"

  src = fetchFromGitHub {
    owner  = "01org";
    repo   = "libva-utils";
    rev    = version;
    sha256 = "0k5v72prcq462x780j9vpqf4ckrpqf536z6say81wpna0l0qbd98";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ libdrm libva ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "VAAPI tools: Video Acceleration API";
    homepage = http://www.freedesktop.org/wiki/Software/vaapi;
    license = licenses.mit;
    maintainers = with maintainers; [ garbas ];
    platforms = platforms.unix;
  };
}
