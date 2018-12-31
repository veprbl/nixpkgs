{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, perl, pythonPackages, libiconv }:

stdenv.mkDerivation rec {
  name = "universal-ctags-${version}";
  version = "2018-12-29";

  src = fetchFromGitHub {
    owner = "universal-ctags";
    repo = "ctags";
    rev = "380fa1c73ada01e20a3c36340d65fc2461d262a1";
    sha256 = "13rrhvy6pf36g220sazl7ik1aifchi98x4gvf7qnh22jgy7ymv1q";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig pythonPackages.docutils ];
  buildInputs = stdenv.lib.optional stdenv.isDarwin libiconv;

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
