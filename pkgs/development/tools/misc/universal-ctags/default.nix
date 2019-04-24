{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, perl, pythonPackages, libiconv,
jansson, libxml2, libyaml, libseccomp }:

stdenv.mkDerivation rec {
  name = "universal-ctags-${version}";
  version = "2019-04-19";

  src = fetchFromGitHub {
    owner = "universal-ctags";
    repo = "ctags";
    rev = "54c1c2b8f80c0e9018c8d099b09bf4dfbcfb7795";
    sha256 = "05aj2dc62dsgdnhw98daha75vij2vlgg8hw1gl7avrw30xp3w8n9";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig pythonPackages.docutils ];
  buildInputs = [ libxml2 jansson libyaml libseccomp ] ++ stdenv.lib.optional stdenv.isDarwin libiconv;

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
