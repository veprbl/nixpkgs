{ stdenv, fetchurl
, libX11, libXext }:

stdenv.mkDerivation rec {
  name = "xdesktopwaves-${version}";
  version = "1.3";

  src = fetchurl {
    url = "https://ayera.dl.sourceforge.net/project/xdesktopwaves/xdesktopwaves/${version}/${name}.tar.gz";
    sha256 = "0y8pwp71qki15xhsw5chr3s967ddj72fw4q7b2ahwqcmc3jiynhq";
  };

  buildInputs = [
    libX11
    libXext
  ];

  installFlags = [
    "BINDIR=$(out)/bin"
    "MAN1DIR=$(out)/share/man/man1"
  ];

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
  '';

  meta = with stdenv.lib; {
    description = "A cellular automata setting the background of your X Windows desktop under water.";
    longDescription = ''
      xdesktopwaves is a cellular automata setting the background of your X Windows desktop under
      water. Windows and mouse are like ships on the sea. Each movement of these ends up in moving
      water waves. You can even have rain and/or storm stirring up the water.
    '';
    homepage = "http://xdesktopwaves.sourceforge.net";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
