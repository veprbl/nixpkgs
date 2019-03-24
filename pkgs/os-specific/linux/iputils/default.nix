{ stdenv, fetchFromGitHub, fetchpatch
, libxslt, docbook5, docbook5_xsl
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
  prePatch = ''
    for f in doc/{custom-man.xsl,meson.build}; do
      substituteInPlace $f  \
        --replace "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl" "${docbook5_xsl}/share/xml/docbook-xsl-ns/manpages/docbook.xsl"
    done

    # remove spaces before xml nodes that end up in output, causing broken manpages
    # (raw groff commands are shown since spaces can't be before command character)
    # Don't have an explanation for why we see this behavior if others don't, not sure.
    sed -i 's,^[ ]*<,<,' doc/*xml
  '';

  nativeBuildInputs = [ meson ninja libxslt.bin pkgconfig gettext libcap docbook5 docbook5_xsl ];
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
