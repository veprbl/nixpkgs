{ stdenv, fetchurl, fetchFromGitHub, ncurses, gettext, python3, makeWrapper, autoreconfHook, asciidoc-full, libxml2 }:

stdenv.mkDerivation rec {
  pname = "calcurse";
  #version = "4.4.0";
  version = "2019-04-11";

  src = fetchFromGitHub {
    owner = "lfos";
    repo = pname;
    rev = "8741334d83aa5f77f1169af70493f394f860779f";
    sha256 = "19bwqcl8d861wx4mcnj5sqn7cpzm6k3a7r4rq6n1sn4j5qm1vmkv";
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
