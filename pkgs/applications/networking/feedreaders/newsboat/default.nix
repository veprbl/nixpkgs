{ stdenv, rustPlatform, fetchFromGitHub, stfl, sqlite, curl, gettext, pkg-config, libxml2, json_c, ncurses
, asciidoctor, libiconv, intltool, Security, Foundation, makeWrapper }:

rustPlatform.buildRustPackage rec {
  pname = "newsboat";
  version = "2.21";

  src = fetchFromGitHub {
    owner = "newsboat";
    repo = "newsboat";
    rev = "r${version}";
    sha256 = "0ignfmh5193bigvk9f057r0r4yaxymxv2afycn2b98w05gljccb6";
  };

  cargoSha256 = "16652i2hbs6d3fam2hdlc947i5nrb3na186zfcb4nfh7hnb7lh8g";

  postPatch = ''
    substituteInPlace Makefile --replace "|| true" ""
  '' + stdenv.lib.optionalString stdenv.isDarwin ''
    # Allow other ncurses versions on Darwin
    substituteInPlace config.sh \
      --replace "ncurses5.4" "ncurses"
  '';

  nativeBuildInputs = [
    pkg-config
    asciidoctor
    gettext
  ] ++ stdenv.lib.optionals stdenv.isDarwin [ makeWrapper ncurses ];

  buildInputs = [ stfl sqlite curl libxml2 json_c ncurses ]
    ++ stdenv.lib.optionals stdenv.isDarwin [ Security Foundation intltool libiconv gettext ];

  postBuild = ''
    make prefix="$out"
  '';

  # TODO: Check if that's still needed
  NIX_CFLAGS_COMPILE = stdenv.lib.optionalString stdenv.isDarwin " -Wno-error=format-security";

  doCheck = true;

  preCheck = ''
    make test
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
    homepage    = "https://newsboat.org/";
    description = "A fork of Newsbeuter, an RSS/Atom feed reader for the text console";
    maintainers = with maintainers; [ dotlambda nicknovitski ];
    license     = licenses.mit;
    platforms   = platforms.unix;
  };
}
