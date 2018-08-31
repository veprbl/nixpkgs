{ stdenv, fetchgit }:

stdenv.mkDerivation rec {
  version = "07-24-16";
  name = "ttyecho-${version}";

  src = fetchgit {
    url = https://github.com/osospeed/ttyecho;
    rev = "beb3ecce88e1c9c84deaaf5bfed99dadfb66ff78";
    sha256 = "09nfm0r7bcg4c710jfbpza582l8ylrpbynmfj4mbchhqbqq343gx";
  };

  installFlags = [
    "DESTDIR=$(out)/bin"
  ];

  meta = with stdenv.lib; {
    description = ''
      Send commands or data to other terminals
    '';
    homepage = http://www.humbug.in/2010/utility-to-send-commands-or-data-to-other-terminals-ttypts;
    platforms = platforms.linux;
    license = licenses.unfree;
    maintainers = with maintainers; [
      eadwu
    ];
  };
}
