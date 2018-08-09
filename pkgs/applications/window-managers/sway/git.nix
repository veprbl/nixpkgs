{ stdenv, fetchFromGitHub
, meson, ninja, pkgconfig, asciidoc, libxslt, docbook_xsl
, wayland, wayland-protocols, wlroots, libxkbcommon, pcre, json_c, dbus
, pango, cairo, libinput, libcap, pam, gdk_pixbuf, libpthreadstubs
, libXdmcp, scdoc
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "2018-08-08";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = "425ee270b423eb961e5e11162b37b1fb187f50ed";
    sha256 = "0m248pb05vwwc7rm9izjw5ixa6ssi2z1n3bzpbwfjjf465rinfji";
  };

  nativeBuildInputs = [
    meson pkgconfig ninja
  ] ++ stdenv.lib.optional buildDocs [ asciidoc libxslt docbook_xsl scdoc ];
  buildInputs = [
    wayland wayland-protocols wlroots libxkbcommon pcre json_c dbus
    pango cairo libinput libcap pam gdk_pixbuf libpthreadstubs
    libXdmcp
  ];

  enableParallelBuilding = true;

  mesonFlags = [
    "-Dsway_version=${version}"
  ];
  #cmakeFlags = "-DVERSION=${version} -DLD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib";

  meta = with stdenv.lib; {
    description = "i3-compatible window manager for Wayland";
    homepage    = http://swaywm.org;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ]; # Trying to keep it up-to-date.
  };
}

