{ stdenv, fetchurl, pkgconfig, freetype, cmake, python }:

stdenv.mkDerivation rec {
  version = "1.3.12";
  name = "graphite2-${version}";

  src = fetchurl {
    url = "https://github.com/silnrsi/graphite/releases/download/"
      + "${version}/${name}.tgz";
    sha256 = "1l1940d8fz67jm6a0x8cjb5p2dv48cvz3wcskwa83hamd70k15fd";
  };

  nativeBuildInputs = [ pkgconfig cmake ];
  buildInputs = [ freetype ];

  patches = stdenv.lib.optionals stdenv.isDarwin [ ./macosx.patch ];

  checkInputs = [ python ];

  meta = with stdenv.lib; {
    description = "An advanced font engine";
    maintainers = [ maintainers.raskin ];
    platforms = platforms.unix;
    license = licenses.lgpl21;
  };
}
