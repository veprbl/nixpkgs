{ stdenv, fetchFromGitHub, gawk, mercury, pandoc, ncurses, gpgme }:

stdenv.mkDerivation rec {
  name = "notmuch-bower-${version}";
  #version = "0.9";
  version = "2018-12-22";

  src = fetchFromGitHub {
    owner = "wangp";
    repo = "bower";
    #rev = version;
    rev = "0d1ec15679b3fdfcaf1c4dbfa7d05e7a55551a0a";
    sha256 = "0vdw8nv9kw0ncyldxdwn8jriyrqzszg973i3h2x4bgjc9s2jb69q";
  };

  nativeBuildInputs = [ gawk mercury pandoc ];

  buildInputs = [ ncurses gpgme ];

  makeFlags = [ "PARALLEL=-j$(NIX_BUILD_CORES)" "bower" "man" ];

  patches = [
    ./0001-convert-inbox-tag-to-single-char-indicator-hide-impo.patch
    ./0002-hide-more-tags-that-would-be-painful-to-mass-change.patch
    ./0003-lists.patch
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv bower $out/bin/
    mkdir -p $out/share/man/man1
    mv bower.1 $out/share/man/man1/
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = https://github.com/wangp/bower;
    description = "A curses terminal client for the Notmuch email system";
    maintainers = with maintainers; [ erictapen ];
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
