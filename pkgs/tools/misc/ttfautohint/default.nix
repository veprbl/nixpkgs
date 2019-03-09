{
  stdenv, lib, fetchurl, fetchgit, pkgconfig, autoreconfHook
, freetype, harfbuzz, libiconv, qtbase
, bison, flex, git
, enableGUI ? true
}:

stdenv.mkDerivation rec {
  version = "1.8.2.1";
  pname = "ttfautohint";

  #src = fetchurl {
  #  url = "mirror://savannah/freetype/${name}.tar.gz";
  #  sha256 = "19w9g1ksr0vyblgcirppj0279gfj5s902jblzgav5a4n2mq42rrq";
  #};

  src = fetchgit {
    url = https://repo.or.cz/ttfautohint.git;
    rev = "89598ef6e23276020d883352735fa65b6a6a981c";
    sha256 = "1djb8j0m6n1kwhb8nyq7bak5rxqhbhjv9x16csccyi41972c6fp6";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  preAutoreconf = ''
    ./bootstrap --no-git --gnulib-srcdir=.gnulib
  '';

  postAutoreconf = ''
    substituteInPlace configure --replace "macx-g++" "macx-clang"
  '';

  nativeBuildInputs = [ pkgconfig autoreconfHook bison flex git ];

  buildInputs = [ freetype harfbuzz libiconv ] ++ lib.optional enableGUI qtbase;

  configureFlags = [ ''--with-qt=${if enableGUI then "${qtbase}/lib" else "no"}'' ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "An automatic hinter for TrueType fonts";
    longDescription = ''
      A library and two programs which take a TrueType font as the
      input, remove its bytecode instructions (if any), and return a
      new font where all glyphs are bytecode hinted using the
      information given by FreeType’s auto-hinting module.
    '';
    homepage = https://www.freetype.org/ttfautohint;
    license = licenses.gpl2Plus; # or the FreeType License (BSD + advertising clause)
    maintainers = with maintainers; [ goibhniu ndowens ];
    platforms = platforms.unix;
  };

}
