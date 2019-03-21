{ stdenv
, fetchFromGitHub
, asciidoc
, docbook_xml_dtd_45
, docbook_xsl
, freetype
, judy
, libGL
, libconfig
, libdrm
, libxml2
, libxslt
, pcre
, pkgconfig
, xlibs
}:
let
  date  = "2019-03-12";
  rev   = "v0.6-17-g271e784";
  xdeps = with xlibs; [
    libXcomposite libXdamage libXrender libXext libXrandr libXinerama
  ];
in
stdenv.mkDerivation rec {
  name    = "NeoComp";
  version = "git-${rev}-${date}";

  src = fetchFromGitHub {
    inherit rev;
    owner  = "DelusionalLogic";
    repo   = name;
    sha256 = "1mp338vz1jm5pwf7pi5azx4hzykmvpkwzx1kw6a9anj272f32zpg";
  };

  buildInputs = xdeps ++ [
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    freetype
    judy
    libGL
    libconfig
    libdrm
    libxml2
    libxslt
    pcre
    pkgconfig
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "CFGDIR=${placeholder "out"}/etc/xdg/neocomp"
    "COMPTON_VERSION=${version}"
  ];

  meta = with stdenv.lib; {
    homepage        = https://github.com/DelusionalLogic/NeoComp;
    license         = licenses.gpl3;
    maintainers     = with maintainers; [ twey ];
    platforms       = platforms.linux;
    description     = "A fork of Compton, a compositor for X11";
    longDescription = ''
      NeoComp is a (hopefully) fast and (hopefully) simple compositor
      for X11, focused on delivering frames from the window to the
      framebuffer as quickly as possible.
    '';
  };
}
