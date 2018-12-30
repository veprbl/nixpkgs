{ pkgs, fetchFromGitHub, stdenv, makeWrapper, taskwarrior, ncurses,
perl, perlPackages, which }:

let
  version = "1.3.beta1";
in
stdenv.mkDerivation {
  name = "vit-${version}";

  src = fetchFromGitHub {
    owner = "scottkosty";
    repo = "vit";
    rev = "v${version}";
    sha256 = "1hxki4m8ahgkzh3d389xrxhq6ac73ihavsw3cn1b4mn1kygcl3j2";
  };

  preConfigure = ''
    substituteInPlace Makefile.in \
      --replace sudo ""
    substituteInPlace configure \
      --replace /usr/bin/perl ${perl}/bin/perl
  '';

  postInstall = ''
    wrapProgram $out/bin/vit --prefix PERL5LIB : $PERL5LIB
  '';

  nativeBuildInputs = [ makeWrapper which ];
  buildInputs = [ taskwarrior ncurses perl ]
    ++ (with perlPackages; [ Curses TryTiny TextCharWidth ]);

  meta = {
    description = "Visual Interactive Taskwarrior";
    maintainers = with pkgs.lib.maintainers; [ ];
    platforms = pkgs.lib.platforms.all;
    license = pkgs.lib.licenses.gpl3;
  };
}

