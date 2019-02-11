{ stdenv, fetchFromGitHub, gawk, mercury, pandoc, ncurses, gpgme }:

stdenv.mkDerivation rec {
  name = "notmuch-bower-${version}";
  version = "0.10.0.1"; # not really

  src = fetchFromGitHub {
    owner = "wangp";
    repo = "bower";
    #rev = version;
    rev = "ddd11c815eddbd129d4e04882a02dcc7e15a42f7";
    sha256 = "0jca310dr2zx0l9xvpnxnrw0vn70chyj7gx95c6lhphhg0zmyjwc";
  };

  nativeBuildInputs = [ gawk mercury pandoc ];

  buildInputs = [ ncurses gpgme ];

  preBuild = ''
    echo "MCFLAGS += --intermod-opt -O6 --verbose" > src/Mercury.params
  '';

  makeFlags = [ "PARALLEL=-j$(NIX_BUILD_CORES)" "bower" "man" ];

  patches = [
    #./0001-Use-some-emoticons-for-status.patch
    #./0002-Good-signature.patch
    #./0003-tick-for-selected.patch
    ./0004-convert-inbox-tag-to-single-char-indicator-hide-impo.patch
    ./0005-hide-more-tags-that-would-be-painful-to-mass-change.patch
    ./0006-lists.patch
    #./0007-tweak-icons-fix-spacing.patch
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
