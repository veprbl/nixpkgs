{ stdenv, fetchFromGitHub
, meson, ninja, pkgconfig, gettext
, libxslt, docbook_xsl, docbook_xml_dtd_44
, libcap, nettle, libidn2, openssl
}:

with stdenv.lib;

let
  time = "20190324";
  # ninfod probably could build on cross, but the Makefile doesn't pass --host
  # etc to the sub configure...
  withNinfod = stdenv.hostPlatform == stdenv.buildPlatform;
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

  prePatch = ''
    for file in doc/custom-man.xsl doc/meson.build; do
      substituteInPlace $file \
        --replace "http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl" "${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl"
    done
  '';

  # ninfod cannot be build with nettle yet:
  patches = [ ./build-ninfod-with-openssl.patch ./timespec.patch ];

  mesonFlags = [
    "-DUSE_CRYPTO=nettle" "-DBUILD_RARPD=true" "-DBUILD_TRACEROUTE6=true"
  ] ++ optional (!withNinfod) "-DBUILD_NINFOD=false"
    ++ optional stdenv.hostPlatform.isMusl "-DUSE_IDN=false";
  # Disable idn usage w/musl: https://github.com/iputils/iputils/pull/111

  nativeBuildInputs = [ meson ninja pkgconfig gettext libxslt.bin ];
  buildInputs = [ libcap nettle ]
    ++ optional (!stdenv.hostPlatform.isMusl) libidn2
    ++ optional withNinfod openssl; # TODO: Build with nettle

  meta = {
    homepage = https://github.com/iputils/iputils;
    description = "A set of small useful utilities for Linux networking";
    license = with licenses; [ gpl2Plus bsd3 sunAsIsLicense ];
    platforms = platforms.linux;
    maintainers = with maintainers; [ primeos lheckemann ];
  };
}
