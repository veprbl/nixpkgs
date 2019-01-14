{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig, perl, pythonPackages, libiconv,
jansson, libxml2, libyaml, libseccomp }:

stdenv.mkDerivation rec {
  name = "universal-ctags-${version}";
  version = "2019-01-14";

  src = fetchFromGitHub {
    owner = "universal-ctags";
    repo = "ctags";
    rev = "3d01d9934e24c1eb7b908191fee7ab9c703a09d8";
    sha256 = "0f8aap87cn0221wdrpq5ywq4bkcn1zraf7kbwzh3shgfiwyhzc79";
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
