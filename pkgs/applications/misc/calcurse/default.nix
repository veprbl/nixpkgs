{ stdenv, fetchurl, fetchFromGitHub, ncurses, gettext, python3, makeWrapper, autoreconfHook, asciidoc-full, libxml2 }:

stdenv.mkDerivation rec {
  pname = "calcurse";
  #version = "4.4.0";
  version = "2019-03-17";

  src = fetchFromGitHub {
    owner = "lfos";
    repo = pname;
    rev = "78a46ac7cbae997979d7c1394328d3d44f9f1df4";
    sha256 = "10k0q2n7mpxvxyb4fzn3n3mzc1byapx8l058jrwmry692wbn6h6h";
  };
  #src = fetchurl {
  #  #url = "https://calcurse.org/files/${pname}-${version}.tar.gz";
  #  sha256 = "0vw2xi6a2lrhrb8n55zq9lv4mzxhby4xdf3hmi1vlfpyrpdwkjzd";
  #};

  patches = [ ./vdirsyncer-quoting.patch ];

  buildInputs = [ ncurses gettext pythonEnv ];
  nativeBuildInputs = [ makeWrapper autoreconfHook asciidoc-full libxml2.bin ];

  # Build Python environment with httplib2 for calcurse-caldav
  pythonEnv = python3.withPackages (ps: with ps; [ httplib2 libxml2 oauth2client ]);


  postInstall = ''
    install -Dm755 contrib/vdir/calcurse-vdirsyncer $out/bin
  '';

  meta = with stdenv.lib; {
    description = "A calendar and scheduling application for the command line";
    longDescription = ''
      calcurse is a calendar and scheduling application for the command line. It helps
      keep track of events, appointments and everyday tasks. A configurable notification
      system reminds users of upcoming deadlines, the curses based interface can be
      customized to suit user needs and a very powerful set of command line options can
      be used to filter and format appointments, making it suitable for use in scripts.
    '';
    homepage = http://calcurse.org/;
    license = licenses.bsd2;
    platforms = platforms.linux;
  };
}
