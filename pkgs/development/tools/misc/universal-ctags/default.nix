{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, perl, pythonPackages, libiconv,
jansson, libxml2, libyaml }:

stdenv.mkDerivation rec {
  name = "universal-ctags-${version}";
  version = "2019-01-06";

  src = fetchFromGitHub {
    owner = "universal-ctags";
    repo = "ctags";
    rev = "284610ba5bbc70247c333c2d92a8c599828e44ab";
    sha256 = "0v9667pkmj7a8ncy7pv8mvwnxk6sa8p7w780b1a5aarppgd6yr84";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig pythonPackages.docutils ];
  buildInputs = [ libxml2 jansson libyaml ] ++ stdenv.lib.optional stdenv.isDarwin libiconv;

  # to generate makefile.in
  autoreconfPhase = ''
    ./autogen.sh
  '';

  configureFlags = [ "--enable-tmpdir=/tmp" ];

  postConfigure = ''
    sed -i 's|/usr/bin/env perl|${perl}/bin/perl|' misc/optlib2c
  '';

  doCheck = true;

  checkFlags = "units";

  meta = with stdenv.lib; {
    description = "A maintained ctags implementation";
    homepage = https://ctags.io/;
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    # universal-ctags is preferred over emacs's ctags
    priority = 1;
    maintainers = [ maintainers.mimadrid ];
  };
}
