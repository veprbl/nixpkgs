{ stdenv, fetchFromGitHub, gawk, mercury, pandoc, ncurses, gpgme }:

stdenv.mkDerivation rec {
  name = "notmuch-bower-${version}";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "wangp";
    repo = "bower";
    rev = version;
    sha256 = "0f8djiclq4rz9isbx18bpzymbvb2q0spvjp982b149hr1my6klaf";
  };

  nativeBuildInputs = [ gawk mercury pandoc ];

  buildInputs = [ ncurses gpgme ];

  preBuild = ''
    echo "MCFLAGS += --intermod-opt -O6 --verbose" > src/Mercury.params
  '';

  makeFlags = [ "PARALLEL=-j$(NIX_BUILD_CORES)" "bower" "man" ];

  patches = [
    ./0001-convert-inbox-tag-to-single-char-indicator-hide-impo.patch
    ./0002-hide-more-tags-that-would-be-painful-to-mass-change.patch
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
