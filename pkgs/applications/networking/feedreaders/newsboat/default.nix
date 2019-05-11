{ stdenv, rustPlatform, fetchurl, fetchFromGitHub, fetchpatch, stfl, sqlite, curl, gettext, pkgconfig, libxml2, json_c, ncurses
, asciidoc, docbook_xml_dtd_45, libxslt, docbook_xsl, libiconv, Security, makeWrapper }:

rustPlatform.buildRustPackage rec {
  #name = "newsboat-${version}";
  pname = "newsboat";
#  version = "2.15";
  version = "2019-05-09";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "1d439ede40dadc55e96fa2884c3e27cc9631f68a";
    sha256 = "191clmzl3wl4rf8fp7md93j1aani8by6rgivqc7hl7zmskac155n";
  };
  #src = fetchurl {
  #  url = "https://newsboat.org/releases/${version}/${name}.tar.xz";
  #  sha256 = "1dqdcp34jmphqf3d8ik0xdhg0s66nd5rky0y8y591nidq29wws6s";
  #};

  cargoSha256 = "05y6lz4zzv0b3pddj8kqhggby885fagyp14p34k5l3l2yqbxhpsl";

  postPatch = ''
    substituteInPlace Makefile --replace "|| true" ""
    # Allow other ncurses versions on Darwin
    substituteInPlace config.sh \
      --replace "ncurses5.4" "ncurses"
  '';

  nativeBuildInputs = [ pkgconfig asciidoc docbook_xml_dtd_45 libxslt docbook_xsl ]
    ++ stdenv.lib.optional stdenv.isDarwin [ makeWrapper libiconv ];

  buildInputs = [ stfl sqlite curl gettext libxml2 json_c ncurses ]
    ++ stdenv.lib.optional stdenv.isDarwin Security;

  postBuild = ''
    make -j$NIX_BUILD_CORES
  '';

  NIX_CFLAGS_COMPILE = "-Wno-error=sign-compare";

  doCheck = true;

  checkPhase = ''
    make test -j$NIX_BUILD_CORES
  '';

  postInstall = ''
    make prefix="$out" install
    cp -r contrib $out
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${stfl}/lib"
    done
  '';

  meta = with stdenv.lib; {
    homepage    = https://newsboat.org/;
    description = "A fork of Newsbeuter, an RSS/Atom feed reader for the text console.";
    maintainers = with maintainers; [ dotlambda nicknovitski ];
    license     = licenses.mit;
    platforms   = platforms.unix;
  };
}
