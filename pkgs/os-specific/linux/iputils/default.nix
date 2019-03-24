{ stdenv, fetchFromGitHub, fetchpatch
, libxslt, docbook_xsl, docbook_xml_dtd_44
, libcap, nettle, libidn2, openssl, libgcrypt
, meson, ninja, pkgconfig, gettext
}:

with stdenv.lib;

let
  time = "20190324";
  sunAsIsLicense = {
    fullName = "AS-IS, SUN MICROSYSTEMS license";
    url = "https://github.com/iputils/iputils/blob/s${time}/rdisc.c";
  };
in stdenv.mkDerivation {
  name = "iputils-${time}";

  src = fetchFromGitHub {
    owner = "iputils";
    repo = "iputils";
    rev = "s${time}";
    sha256 = "0b755gv3370c0rrphx14mrsqjb396zqnsm9lsws842a4k4zrqmvi";
  };

  mesonFlags = [
    "-DBUILD_TRACEROUTE6=true"
    "-DBUILD_RARPD=true"
  ];

  patches = [ ./timespec.patch ];

  nativeBuildInputs = [ meson ninja libxslt.bin pkgconfig gettext libcap ];
  buildInputs = [ libcap nettle openssl libgcrypt ]
    ++ optional (!stdenv.hostPlatform.isMusl) libidn2;

  meta = {
    homepage = https://github.com/iputils/iputils;
    description = "A set of small useful utilities for Linux networking";
    license = with licenses; [ gpl2Plus bsd3 sunAsIsLicense ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ primeos lheckemann ];
  };
}
