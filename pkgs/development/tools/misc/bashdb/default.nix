{stdenv, fetchurl, emacs}:

stdenv.mkDerivation rec {
  name = "bashdb-${version}";
  version = "4.3-0.91";
  src = fetchurl {
    url = "http://her.gr.distfiles.macports.org/mirrors/macports/mpdistfiles/bashdb/bashdb-4.3-0.91.tar.gz";
    sha256 = "1cffxzsp4i3jzbr3aji8rixagfq463297ma3accz7fals9wndmx8";
  };
  buildInputs = [];
  propagatedBuildInputs = [emacs];
  configureFlags = "";

  patches = [  ];

  meta = {
    # homepage = http://www.gnu.org/software/ddd;
    # description = "Graphical front-end for command-line debuggers";
    # license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
  };
}
